import Foundation
import APIKit
import Himotoki

class GitHub: API {
    override class var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    class Endpoint {
        // https://developer.github.com/v3/search/#search-repositories
        class SearchRepositories: APIKit.Request {
            enum Sort: String {
                case Stars = "stars"
                case Forks = "forks"
                case Updated = "updated"
            }

            enum Order: String {
                case Ascending = "asc"
                case Descending = "desc"
            }

            typealias Response = [Repository]

            let query: String
            let sort: Sort
            let order: Order

            var URLRequest: NSURLRequest? {
                return GitHub.URLRequest(
                    method: .GET,
                    path: "/search/repositories",
                    parameters: ["q": query, "sort": sort.rawValue, "order": order.rawValue]
                )
            }

            init(query: String, sort: Sort = .Stars, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            class func responseFromObject(object: AnyObject) -> Response? {
                return object["items"].flatMap(decode) ?? []
            }
        }

        // https://developer.github.com/v3/search/#search-users
        class SearchUsers: APIKit.Request {
            enum Sort: String {
                case Followers = "followers"
                case Repositories = "repositories"
                case Joined = "joined"
            }

            enum Order: String {
                case Ascending = "asc"
                case Descending = "desc"
            }

            typealias Response = [User]

            let query: String
            let sort: Sort
            let order: Order

            var URLRequest: NSURLRequest? {
                return GitHub.URLRequest(
                    method: .GET,
                    path: "/search/users",
                    parameters: ["q": query, "sort": sort.rawValue, "order": order.rawValue]
                )
            }

            init(query: String, sort: Sort = .Followers, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            class func responseFromObject(object: AnyObject) -> Response? {
                return object["items"].flatMap(decode) ?? []
            }
        }
    }
}
