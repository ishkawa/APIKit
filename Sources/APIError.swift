import Foundation

public enum APIError: ErrorType {
    /// Error of `NSURLSession`.
    case ConnectionError(NSError)

    /// Invalid `Request.baseURL`.
    case InvalidBaseURL(NSURL)

    /// Error in `Request.configureURLRequest()`.
    case ConfigurationError(ErrorType)

    /// Error in `RequestBodyBuilder.buildBodyFromObject()`.
    case RequestBodySerializationError(ErrorType)

    /// Indicates `NSHTTPURLResponse.statusCode` is not contained in `Request.statusCode`.
    /// Second associated value is return value of `errorFromObject()`.
    case UnacceptableStatusCode(Int, ErrorType)

    /// Error in `ResponseBodyParser.parseData()`.
    case ResponseBodyDeserializationError(ErrorType)

    /// Indicates `responseFromObject()` or `errorFromObject()` returned nil.
    case InvalidResponseStructure(AnyObject)

    /// Failed to cast `URLResponse` to `NSHTTPURLResponse`.
    case NotHTTPURLResponse(NSURLResponse?)
}
