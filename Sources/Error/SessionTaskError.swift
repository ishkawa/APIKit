import Foundation

public enum SessionTaskError: ErrorType {
    /// Error of `NSURLSession`.
    case ConnectionError(NSError)

    /// Error while creating `NSURLReqeust` from `Request`.
    case RequestError(ErrorType)

    /// Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.
    case ResponseError(ErrorType)
}
