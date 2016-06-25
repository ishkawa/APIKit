import Foundation

/// `HTTPMethod` represents HTTP methods.
public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case HEAD
    case DELETE
    case PATCH
    case TRACE
    case OPTIONS
    case CONNECT

    /// Indicates if the query parameters are suitable for parameters.
    public var prefersQueryParameters: Bool {
        switch self {
        case .GET, .HEAD, .DELETE:
            return true

        default:
            return false
        }
    }
}
