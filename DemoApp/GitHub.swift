import Foundation
import APIKit
import LlamaKit

class GitHub: API {
    override class var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    override class var requestBodyBuilder: RequestBodyBuilder {
        return .JSON(writingOptions: nil)
    }

    override class var responseBodyParser: ResponseBodyParser {
        return .JSON(readingOptions: nil)
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
                return GitHub.URLRequest(.GET, "/search/repositories", ["q": query, "sort": sort.rawValue, "order": order.rawValue])
            }

            init(query: String, sort: Sort = .Stars, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            class func responseFromObject(object: AnyObject) -> Response? {
                var repositories = [Repository]()

                if let dictionaries = object["items"] as? [NSDictionary] {
                    for dictionary in dictionaries {
                        if let repository = Repository(dictionary: dictionary) {
                            repositories.append(repository)
                        }
                    }
                }

                return repositories
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
                return GitHub.URLRequest(.GET, "/search/users", ["q": query, "sort": sort.rawValue, "order": order.rawValue])
            }

            init(query: String, sort: Sort = .Followers, order: Order = .Ascending) {
                self.query = query
                self.sort = sort
                self.order = order
            }

            class func responseFromObject(object: AnyObject) -> Response? {
                var users = [User]()

                if let dictionaries = object["items"] as? [NSDictionary] {
                    for dictionary in dictionaries {
                        if let user = User(dictionary: dictionary) {
                            users.append(user)
                        }
                    }
                }
                
                return users
            }
        }
    }
}
