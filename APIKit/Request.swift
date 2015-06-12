import Foundation
import Result

public protocol Request {
    // required
    typealias Response
    var method: Method { get }
    var path: String { get }
    func buildResponseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response

    var parameters: [String: AnyObject] { get }
    var baseURL: NSURL { get }
    var acceptableStatusCodes: Set<Int> { get }
    var requestBodyBuilder: RequestBodyBuilder { get }
    var responseBodyParser: ResponseBodyParser { get }

    func buildURLRequest() throws -> NSURLRequest
    func buildErrorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType
}

public extension Request {
    public var parameters: [String: AnyObject] {
        return [:]
    }

    public var baseURL: NSURL {
        fatalError("Request.baseURL must be overrided.")
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

    public func buildURLRequest() throws -> NSURLRequest {
        guard let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) else {
            throw APIKitError.InvalidBaseURL
        }

        let request = NSMutableURLRequest()

        switch method {
        case .GET, .HEAD, .DELETE:
            components.query = URLEncodedSerialization.stringFromObject(parameters, encoding: NSUTF8StringEncoding)

        default:
            switch requestBodyBuilder.buildBodyFromObject(parameters) {
            case .Success(let result):
                request.HTTPBody = result

            case .Failure:
                throw APIKitError.InvalidParameters
            }
        }

        components.path = (components.path ?? "").stringByAppendingPathComponent(path)
        request.URL = components.URL
        request.HTTPMethod = method.rawValue
        request.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
        request.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")

        return request
    }

    public func buildErrorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType {
        return APIKitError.UnacceptableStatusCode
    }
}
