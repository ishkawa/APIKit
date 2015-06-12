import Foundation

// TODO: more detailed and comprehensive errors
public enum APIKitError: ErrorType {
    case InvalidBaseURL
    case InvalidParameters
    case CannotBuildURLRequest
    case CannotBuildURLSessionTask
    case CannotBuildResponseObject(underlyingError: ErrorType)
    case NoURLResponse
    case UnacceptableStatusCode
    case ConnectionError(underlyingError: ErrorType)
    case ResponseBodyParserError(underlyingError: ErrorType)
    case ResponseError(underlyingError: ErrorType)
}
