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

    /// A parameter dictionary for the request. You can pass `NSNull()` as a
    /// value for nullable keys, those should be existed in the encoded query or
    /// the request body.
    var parameters: [String: AnyObject] { get }
    
    /// Additional HTTP header fields. RequestType will add `Accept` and `Content-Type` automatically.
    /// You can override values for those fields here.
    var HTTPHeaderFields: [String: String] { get }

    /// You can add any configurations here
    ///
    /// - Throws: ErrorType
    func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest

    /// An object that builds body of HTTP request.
    var requestBodyBuilder: RequestBodyBuilder { get }

    /// An object that parses body of HTTP response.
    var responseBodyParser: ResponseBodyParser { get }

    /// Build `Response` instance from raw response object.
    /// This method will be called if `acceptableStatusCode` contains status code of NSHTTPURLResponse.
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response

    func validateObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject
}

/// Default implementation of RequestType protocol
public extension RequestType {
    public var parameters: [String: AnyObject] {
        return [:]
    }

    public var HTTPHeaderFields: [String: String] {
        return [:]
    }
    
    public var requestBodyBuilder: RequestBodyBuilder {
        return .JSON(writingOptions: [])
    }

    public var responseBodyParser: ResponseBodyParser {
        return .JSON(readingOptions: [])
    }

    public func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
        return URLRequest
    }

    func validateObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject {
        let acceptableStatusCode = 200..<300
        guard acceptableStatusCode.contains(URLResponse.statusCode) else {
            throw FatalError("Received unacceptable status code \(URLResponse.statusCode) and object \(object)")
        }

        return object
    }

    public func buildURLRequest() throws -> NSURLRequest {
        let URL = path.isEmpty ? baseURL : baseURL.URLByAppendingPathComponent(path)
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) else {
            throw FatalError("Invalid base URL \(baseURL) in \(self).")
        }

        let URLRequest = NSMutableURLRequest()
        let parameters = self.parameters

        switch method {
        case .GET, .HEAD, .DELETE:
            if parameters.count > 0 {
                components.percentEncodedQuery = URLEncodedSerialization.stringFromDictionary(parameters)
            }
            
        default:
            URLRequest.HTTPBody = try requestBodyBuilder.buildBodyFromObject(parameters)
            URLRequest.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
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
