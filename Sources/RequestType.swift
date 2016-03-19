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

    var queryParameters: [String: AnyObject]? { get }
    var bodyParameters: BodyParametersType? { get }
    
    /// Additional HTTP header fields. RequestType will add `Accept` and `Content-Type` automatically.
    /// You can override values for those fields here.
    var HTTPHeaderFields: [String: String] { get }

    /// An object that states Content-Type to accept and parses response body .
    var dataParser: DataParserType { get }

    /// Intercept `NSURLRequest` which is created by `RequestType.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `Session.sendRequest()` truns `.Failure(.RequestError(error))`.
    ///
    /// - Throws: ErrorType
    func interceptURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest

    /// Intercept response `AnyObject` and `NSHTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.sendRequest()` turns `.Failure(.ResponseError(error))`.
    ///
    /// - Throws: ErrorType
    func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject

    /// Build `Response` instance from raw response object. This method is called after
    /// `interceptObject(:URLResponse:)` if it does not throw any error.
    ///
    /// - Throws: ErrorType
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response
}

/// Default implementation of RequestType protocol
public extension RequestType {
    public var parameters: AnyObject? {
        return nil
    }

    public var queryParameters: [String: AnyObject]? {
        guard let parameters = parameters as? [String: AnyObject] where method.prefersQueryParameters else {
            return nil
        }

        return parameters
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

    public var dataParser: DataParserType {
        return JSONDataParser(readingOptions: [])
    }

    public func interceptURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
        return URLRequest
    }

    public func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject {
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
            components.percentEncodedQuery = URLEncodedSerialization.stringFromDictionary(queryParameters)
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
        URLRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")
        
        HTTPHeaderFields.forEach { key, value in
            URLRequest.setValue(value, forHTTPHeaderField: key)
        }

        try interceptURLRequest(URLRequest)

        return URLRequest
    }

    public func parseData(data: NSData, URLResponse: NSHTTPURLResponse) throws -> Response {
        let parsedObject = try dataParser.parseData(data)
        let passedObject = try interceptObject(parsedObject, URLResponse: URLResponse)
        return try responseFromObject(passedObject, URLResponse: URLResponse)
    }
}
