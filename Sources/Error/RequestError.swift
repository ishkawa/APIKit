import Foundation

/// `RequestError` represents a common error that occurs while building `NSURLRequest` from `RequestType`.
enum RequestError: ErrorType {
    case InvalidBaseURL(NSURL)
    case UnexpectedURLRequest(NSURLRequest)
}
