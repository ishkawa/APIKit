import Foundation

/// `RequestError` represents a common error that occurs while building `URLRequest` from `RequestType`.
public enum RequestError: Error {
    /// Indicates `baseURL` of a type that conforms `RequestType` is invalid.
    case InvalidBaseURL(URL)

    /// Indicates `URLRequest` built by `RequestType.buildURLRequest` is unexpected.
    case UnexpectedURLRequest(URLRequest)
}
