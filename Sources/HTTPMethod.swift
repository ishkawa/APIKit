import Foundation

/// `HTTPMethod` represents HTTP methods.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case patch = "PATCH"
    case trace = "TRACE"
    case options = "OPTIONS"
    case connect = "CONNECT"

    /// Indicates if the query parameters are suitable for parameters.
    public var prefersQueryParameters: Bool {
        switch self {
        case .get, .head, .delete:
            return true

        default:
            return false
        }
    }
}
