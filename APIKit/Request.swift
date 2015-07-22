import Foundation
import Result

/// Request protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - typealias Response
/// - var baseURL: NSURL
/// - var method: Method
/// - var path: String
/// - func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response?
public protocol Request {
    /// Type represents a model object
    typealias Response

    /// Configurations of request
    var baseURL: NSURL { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var parameters: [String: AnyObject] { get }

    /// You can add any configurations here
    ///
    /// - Throws: ErrorType
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
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response?

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
        return NSError(domain: "APIKitErrorDomain", code: 0, userInfo: nil)
    }

    // Use Result here because `throws` loses type info of an error (in Swift 2 beta 2)
    internal func createTaskInURLSession(URLSession: NSURLSession) -> Result<NSURLSessionDataTask, APIError> {
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) else {
            return .Failure(.InvalidBaseURL(baseURL))
        }

        let URLRequest = NSMutableURLRequest()

        switch method {
        case .GET, .HEAD, .DELETE:
            components.query = URLEncodedSerialization.stringFromDictionary(parameters)

        default:
            do {
                URLRequest.HTTPBody = try requestBodyBuilder.buildBodyFromObject(parameters)
            } catch {
                return .Failure(.RequestBodySerializationError(error))
            }
        }

        components.path = (components.path ?? "").stringByAppendingPathComponent(path)
        URLRequest.URL = components.URL
        URLRequest.HTTPMethod = method.rawValue
        URLRequest.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
        URLRequest.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")

        do {
            try configureURLRequest(URLRequest)
        } catch {
            return .Failure(.ConfigurationError(error))
        }

        let task = URLSession.dataTaskWithRequest(URLRequest)

        return .Success(task)
    }

    // Use Result here because `throws` loses type info of an error (in Swift 2 beta 2)
    internal func parseData(data: NSData, URLResponse: NSURLResponse?) -> Result<Self.Response, APIError> {
        guard let HTTPURLResponse = URLResponse as? NSHTTPURLResponse else {
            return .Failure(.NotHTTPURLResponse(URLResponse))
        }

        let object: AnyObject
        do {
            object = try responseBodyParser.parseData(data)
        } catch {
            return .Failure(.ResponseBodyDeserializationError(error))
        }

        if !acceptableStatusCodes.contains(HTTPURLResponse.statusCode) {
            guard let error = errorFromObject(object, URLResponse: HTTPURLResponse) else {
                return .Failure(.InvalidResponseStructure(object))
            }
            return .Failure(.UnacceptableStatusCode(HTTPURLResponse.statusCode, error))
        }

        guard let response = responseFromObject(object, URLResponse: HTTPURLResponse) else {
            return .Failure(.InvalidResponseStructure(object))
        }

        return .Success(response)
    }
}
