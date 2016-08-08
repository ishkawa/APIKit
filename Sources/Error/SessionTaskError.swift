import Foundation

/// `SessionTaskError` represents an error that occurs while task for a request.
public enum SessionTaskError: Error {
    /// Error of `URLSession`.
    case ConnectionError(Error)

    /// Error while creating `URLReqeust` from `Request`.
    case RequestError(Error)

    /// Error while creating `RequestType.Response` from `(Data, URLResponse)`.
    case ResponseError(Error)
}
