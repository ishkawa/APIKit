import Foundation

/// `RequestError` represents a common error that occurs while building `URLRequest` from `Request`.
public enum RequestError: Error {
    /// Indicates `baseURL` of a type that conforms `Request` is invalid.
    case invalidBaseURL(URL)

    /// Indicates `URLRequest` built by `Request.buildURLRequest` is unexpected.
    case unexpectedURLRequest(URLRequest)
}
