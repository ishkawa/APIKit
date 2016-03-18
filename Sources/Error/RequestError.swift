import Foundation

enum RequestError: ErrorType {
    case InvalidBaseURL(NSURL)
    case UnexpectedURLRequest(NSURLRequest)
}
