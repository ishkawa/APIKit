import Foundation

public enum ResponseError: ErrorType {
    case NonHTTPURLResponse(NSURLResponse?)
    case UnacceptableStatusCode(Int)
    case UnexpectedObject(AnyObject)
}
