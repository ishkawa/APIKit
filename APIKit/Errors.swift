import Foundation

// TODO: more detailed and comprehensive errors
public enum APIKitError: ErrorType {
    case CannotBuildURLRequest
    case ConnectionError(underlyingError: NSError)
    case UnacceptableStatusCode(ErrorType?)
    case UnexpectedResponse
}
