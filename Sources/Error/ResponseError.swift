import Foundation

/// `ResponseError` represents a common error that occurs while getting `RequestType.Response`
/// from raw result tuple `(NSData?, NSURLResponse?, NSError?)`.
public enum ResponseError: ErrorType {
    case NonHTTPURLResponse(NSURLResponse?)
    case UnacceptableStatusCode(Int)
    case UnexpectedObject(AnyObject)
}
