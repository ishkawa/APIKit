import Foundation

enum ResponseError: ErrorType {
    case NonHTTPResponse(NSURLResponse?)
}
