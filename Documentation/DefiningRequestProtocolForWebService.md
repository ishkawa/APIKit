# Defining Request Protocol for Web Service

Most web APIs have common configurations such as base URL, authorization header fields and MIME type to accept. For example, GitHub API has common base URL `https://api.github.com`, authorization header field `Authorization` and MIME type `application/json`. Protocol to express such common interfaces and default implementations is useful in defining many request types.

We define `GitHubRequest` to give common configuration for example.

1. [Giving default implementation to Request components](#giving-default-implementation-to-request-components)
2. [Throwing custom errors web API returns](#throwing-custom-errors-web-api-returns)

## Giving default implementation to Request components

### Base URL

First of all, we give default implementation for `baseURL`.

```swift
import APIKit

protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}
```

### JSON Mapping

There are several JSON mapping library such as [Himotoki](https://github.com/ikesyo/Himotoki), [Argo](https://github.com/thoughtbot/Argo) and [Unbox](https://github.com/JohnSundell/Unbox). These libraries provide protocol that define interface to decode `Any` into JSON model type. If you adopt one of them, you can give default implementation to `response(from:urlResponse:)`. Here is an example of default implementation with Himotoki:

```swift
import Himotoki

extension GitHubRequest where Response: Decodable {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        return try Response.decodeValue(object)
    }
}
```

### Defining request types

Since `GitHubRequest` has default implementations of `baseURL` and `response(from:urlResponse:)`, all you have to implement to conform to `GitHubRequest` are 3 components, `Response`, `method` and `path`.

```swift
import APIKit
import Himotoki

final class GitHubAPI {
    struct RateLimitRequest: GitHubRequest {
        typealias Response = RateLimit

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/rate_limit"
        }
    }

    struct SearchRepositoriesRequest: GitHubRequest {
        let query: String

        // MARK: Request
        typealias Response = SearchResponse<Repository>

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/search/repositories"
        }

        var parameters: Any? {
            return ["q": query]
        }
    }
}

struct RateLimit: Decodable {
    let limit: Int
    let remaining: Int

    static func decode(_ e: Extractor) throws -> RateLimit {
        return try RateLimit(
            limit: e.value(["rate", "limit"]),
            remaining: e.value(["rate", "remaining"]))
    }
}

struct Repository: Decodable {
    let id: Int64
    let name: String

    static func decode(_ e: Extractor) throws -> Repository {
        return try Repository(
            id: e.value("id"),
            name: e.value("name"))
    }
}

struct SearchResponse<Item: Decodable>: Decodable {
    let items: [Item]
    let totalCount: Int

    static func decode(_ e: Extractor) throws -> SearchResponse {
        return try SearchResponse(
            items: e.array("items"),
            totalCount: e.value("total_count"))
    }
}
```

It is useful for code completion to nest request types in a utility class like `GitHubAPI` above.

## Throwing custom errors web API returns

Most web APIs define error response to notify what happened on the server. For example, GitHub API defines errors [like this](https://developer.github.com/v3/#client-errors). `interceptObject(_:URLResponse:)` in `Request` gives us a chance to determine if the response is an error. If the response is an error, you can create custom error object from the response object and throw the error in `interceptObject(_:URLResponse:)`.

Here is an example of handling [GitHub API errors](https://developer.github.com/v3/#client-errors):

```swift
// https://developer.github.com/v3/#client-errors
struct GitHubError: Error {
    let message: String

    init(object: Any) {
        let dictionary = object as? [String: Any]
        message = dictionary?["message"] as? String ?? "Unknown error occurred"
    }
}

extension GitHubRequest {
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard 200..<300 ~= urlResponse.statusCode else {
            throw GitHubError(object: object)
        }

        return object
    }
}
```

The custom error you throw in `intercept(object:urlResponse:)` can be retrieved from call-site as `.failure(.responseError(GitHubError))`.

```swift
let request = GitHubAPI.SearchRepositoriesRequest(query: "swift")

Session.send(request) { result in
    switch result {
    case .success(let response):
        print(response)

    case .failure(let error):
        self.printError(error)
    }
}

func printError(_ error: SessionTaskError) {
    switch error {
    case .responseError(let error as GitHubError):
        print(error.message) // Prints message from GitHub API

    case .connectionError(let error):
        print("Connection error: \(error)")

    default:
        print("System error :bow:")
    }
}
```
