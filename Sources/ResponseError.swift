import Foundation

public enum ResponseError: ErrorType {
    case NonHTTPResponse(NSURLResponse?)
    case UnacceptableStatusCode(Int)
}
