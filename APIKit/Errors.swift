import Foundation

public enum APIKitError: ErrorType {
    case InvalidRequest
    case UnexpectedResponse
    case ConnectionError(error: NSError)
    case ResponseError(error: ErrorType)
}
