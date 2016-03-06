import Foundation

public enum APIError: ErrorType {
    /// Error of `NSURLSession`.
    case ConnectionError(NSError)

    /// Error while creating `NSURLReqeust` from `Request`.
    case RequestError(ErrorType)

    /// Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.
    case ResponseError(ErrorType)
}
