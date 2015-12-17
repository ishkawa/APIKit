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

/// Default implementation of RequestType protocol
public extension RequestType {
    public var parameters: [String: AnyObject] {
        return [:]
    }

    public var HTTPHeaderFields: [String: String] {
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
        return NSError(domain: "APIKitErrorDomain", code: 0, userInfo: ["object":object, "URLResponse": URLResponse])
    }
    
    // Use Result here because `throws` loses type info of an error.
    // This method is not overridable. If you need to add customization, override configureURLRequest.
    public func buildURLRequest() -> Result<NSURLRequest, APIError> {
        let URL = path.isEmpty ? baseURL : baseURL.URLByAppendingPathComponent(path)
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) else {
            return .Failure(.InvalidBaseURL(baseURL))
        }

        let URLRequest = NSMutableURLRequest()
        let parameters = self.parameters

        switch method {
        case .GET, .HEAD, .DELETE:
            if parameters.count > 0 {
                components.percentEncodedQuery = URLEncodedSerialization.stringFromDictionary(parameters)
            }
            
        default:
            do {
                URLRequest.HTTPBody = try requestBodyBuilder.buildBodyFromObject(parameters)
                URLRequest.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
            } catch {
                return .Failure(.RequestBodySerializationError(error))
            }
        }

        URLRequest.URL = components.URL
        URLRequest.HTTPMethod = method.rawValue
        URLRequest.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")
        
        HTTPHeaderFields.forEach { key, value in
            URLRequest.setValue(value, forHTTPHeaderField: key)
        }

        do {
            try configureURLRequest(URLRequest)
        } catch {
            return .Failure(.ConfigurationError(error))
        }
        
        return .Success(URLRequest)
    }

    // Use Result here because `throws` loses type info of an error (in Swift 2 beta 2)
    public func parseData(data: NSData, URLResponse: NSURLResponse?) -> Result<Self.Response, APIError> {
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
