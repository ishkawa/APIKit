import Foundation

/// `RequestError` represents a common error that occurs while building `NSURLRequest` from `RequestType`.
public enum RequestError: ErrorType {
    case InvalidBaseURL(NSURL)
    case UnexpectedURLRequest(NSURLRequest)
}
