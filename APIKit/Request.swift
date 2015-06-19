import Foundation
import Result

/// Request protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - typealias Response
/// - var baseURL: NSURL
/// - var method: Method
/// - var path: String
/// - func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response
public protocol Request {
    /// Type represents a model object
    typealias Response

    /// Configurations of request
    var baseURL: NSURL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }

    /// You can add any configurations here
    func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest

    /// Set of status code that indicates success.
    /// `responseFromObject(_:URLResponse:)` will be called if this contains NSHTTPURLResponse.statusCode.
    /// Otherwise, `errorFromObject(_:URLResponse:)` will be called.
    var acceptableStatusCodes: Set<Int> { get }

    /// An object that builds body of HTTP request.
    var requestBodyBuilder: RequestBodyBuilder { get }

    /// An object that parses body of HTTP response.
    var responseBodyParser: ResponseBodyParser { get }

    /// Build `Response` instance from raw response object.
    /// This method will be called if `acceptableStatusCode` contains status code of NSHTTPURLResponse.
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response

    /// Build `ErrorType` instance from raw response object.
    /// This method will be called if `acceptableStatusCode` does not contain status code of NSHTTPURLResponse.
    func errorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType?
}

/// Default implementation of Request protocol
public extension Request {
    public var parameters: [String: AnyObject] {
        return [:]
    }

    public var acceptableStatusCodes: Set<Int> {
        return Set(200..<300)
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

    public func errorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType? {
        return nil
    }

    internal func buildURLRequest() throws -> NSURLRequest {
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) else {
            throw APIKitError.CannotBuildURLRequest
        }

        let request = NSMutableURLRequest()

        switch method {
        case .GET, .HEAD, .DELETE:
            components.query = try URLEncodedSerialization.stringFromObject(parameters, encoding: NSUTF8StringEncoding)

        default:
            request.HTTPBody = try requestBodyBuilder.buildBodyFromObject(parameters)
        }

        components.path = (components.path ?? "").stringByAppendingPathComponent(path)
        request.URL = components.URL
        request.HTTPMethod = method.rawValue
        request.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
        request.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")

        try configureURLRequest(request)

        return request
    }
}
