import Foundation

/// `SessionTaskError` represents an error that occurs while task for a request.
public enum SessionTaskError: ErrorType {
    /// Error of `NSURLSession`.
    case ConnectionError(ErrorType)

    /// Error while creating `NSURLReqeust` from `Request`.
    case RequestError(ErrorType)

    /// Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.
    case ResponseError(ErrorType)
}
