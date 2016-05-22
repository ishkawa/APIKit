import Foundation

/// `RequestError` represents a common error that occurs while building `NSURLRequest` from `RequestType`.
public enum RequestError: ErrorType {
    /// Indicates `baseURL` of a type that conforms `RequestType` is invalid.
    case InvalidBaseURL(NSURL)

    /// Indicates `NSURLRequest` built by `RequestType.buildURLRequest` is unexpected.
    case UnexpectedURLRequest(NSURLRequest)
}
