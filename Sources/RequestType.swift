import Foundation
import Result

/// RequestType protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - typealias Response
/// - var baseURL: NSURL
/// - var method: Method
/// - var path: String
/// - func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response?
public protocol RequestType {
    /// Type represents a model object
    typealias Response

    /// Configurations of request
    var baseURL: NSURL { get }
    var method: HTTPMethod { get }
    var path: String { get }

    /// Convenience property for queryParameters and bodyParameters.
    var parameters: AnyObject? { get }

    var queryParameters: [NSURLQueryItem]? { get }
    var bodyParameters: BodyParametersType? { get }
    
    /// Additional HTTP header fields. RequestType will add `Accept` and `Content-Type` automatically.
    /// You can override values for those fields here.
    var HTTPHeaderFields: [String: String] { get }

    /// You can add any configurations here
    ///
    /// - Throws: ErrorType
    func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest

    /// An object that parses body of HTTP response.
    var responseBodyParser: ResponseBodyParser { get }

    /// Validate `AnyObject` instance, which is a result of response body parse, using `AnyObject`
    /// instance itself and `NSHTTPURLResponse`. If an error is thrown in this method, the result
    /// of `Session.sendRequest()` turns `.Failure(.ResponseError(error))`.
    ///
    /// - Throws: ErrorType
    func validateObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject

    /// Build `Response` instance from raw response object. This method is called after
    /// `validateObject(:URLResponse:)` if it does not throw any error.
    ///
    /// - Throws: ErrorType
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response
}

/// Default implementation of RequestType protocol
public extension RequestType {
    public var parameters: AnyObject? {
        return nil
    }

    public var queryParameters: [NSURLQueryItem]? {
        guard let parameters = parameters as? [String: AnyObject] where method.prefersQueryParameters else {
            return nil
        }

        return parameters.map { key, value in
            let string: String?

            if value is NSNull {
                string = nil
            } else {
                string = value as? String ?? "\(value)"
            }

            return NSURLQueryItem(name: key, value: string)
        }
    }

    public var bodyParameters: BodyParametersType? {
        guard let parameters = parameters where !method.prefersQueryParameters else {
            return nil
        }

        return JSONBodyParameters(JSONObject: parameters)
    }


    public var HTTPHeaderFields: [String: String] {
        return [:]
    }
    
    public var responseBodyParser: ResponseBodyParser {
        return .JSON(readingOptions: [])
    }

    public func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
        return URLRequest
    }

    func validateObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject {
        guard (200..<300).contains(URLResponse.statusCode) else {
            throw ResponseError.UnacceptableStatusCode(URLResponse.statusCode)
        }
        return object
    }

    public func buildURLRequest() throws -> NSURLRequest {
        let URL = path.isEmpty ? baseURL : baseURL.URLByAppendingPathComponent(path)
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) else {
            throw RequestError.InvalidBaseURL(baseURL)
        }

        let URLRequest = NSMutableURLRequest()

        if let queryParameters = queryParameters where !queryParameters.isEmpty {
            components.queryItems = queryParameters
        }

        if let bodyParameters = bodyParameters {
            URLRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")

            switch try bodyParameters.buildEntity() {
            case .Data(let data):
                URLRequest.HTTPBody = data

            case .InputStream(let inputStream):
                URLRequest.HTTPBodyStream = inputStream
            }
        }

        URLRequest.URL = components.URL
        URLRequest.HTTPMethod = method.rawValue
        URLRequest.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")
        
        HTTPHeaderFields.forEach { key, value in
            URLRequest.setValue(value, forHTTPHeaderField: key)
        }

        try configureURLRequest(URLRequest)

        return URLRequest
    }

    public func parseData(data: NSData, URLResponse: NSHTTPURLResponse) throws -> Response {
        let parsedObject = try responseBodyParser.parseData(data)
        let validatedObject = try validateObject(parsedObject, URLResponse: URLResponse)
        return try responseFromObject(validatedObject, URLResponse: URLResponse)
    }
}
