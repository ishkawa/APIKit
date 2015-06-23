import Foundation

public enum APIKitError: ErrorType {
    case InvalidRequest
    case UnexpectedResponse
    case ConnectionError(NSError)
    case ResponseError(ErrorType)
}
