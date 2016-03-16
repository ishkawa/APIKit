import Foundation

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

    var prefersQueryParameters: Bool {
        switch self {
        case .GET, .HEAD, .DELETE:
            return true

        default:
            return false
        }
    }
}
