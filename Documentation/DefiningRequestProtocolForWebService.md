# Defining Request Protocol for Web Service

Most web APIs have common configurations such as base URL, authorization header fields and MIME type to accept. For example, GitHub API has common base URL `https://api.github.com`, authorization header field `Authorization` and MIME type `application/json`. Protocol to express such common interfaces and default implementations is useful in defining many request types.

We define `GitHubRequestType` to give common configuration for example.

## Giving default implementation to RequestType components

### Base URL

First of all, we give default implementation for `baseURL`.

```swift
protocol GitHubRequestType: RequestType {

}

extension GitHubRequestType {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}
```

### JSON Mapping

There are several JSON mapping library such as [Himotoki](https://github.com/ikesyo/Himotoki), [Argo](https://github.com/thoughtbot/Argo) and [Unbox](https://github.com/JohnSundell/Unbox). These libraries provide protocol that define interface to decode `AnyObject` into JSON model type. If you adopt one of them, you can give default implementation to `responseFromObject()`. Here is an example of default implementation with Himotoki 2:

```swift
import Himotoki

extension GitHubRequestType where Response: Decodable {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return try decodeValue(object)
    }
}
```

### Defining request types

Since `GitHubRequestType` has default implementations of `baseURL` and `responseFromObject()`, all you have to implement to conform to `GitHubRequestType` are 3 components, `Response`, `method` and `path`.

```swift
final class GitHubAPI {
    struct RateLimitRequest {
        typealias Response = RateLimit

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/rate_limit"
        }
    }

    struct SearchRepositoriesRequest: GitHubRequestType {
        let query: String

        // MARK: RequestType
        typealias Response = SearchResponse<Repository>

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/search/repositories"
        }

        var parameters: AnyObject? {
            return ["q": query]
        }
    }
}
```

It is useful for code completion to nest request types in a utility class like `GitHubAPI` above.

## Throwing custom errors web API returns

Most web APIs define error response to notify what happened on the server. For example, GitHub API defines errors [like this](https://developer.github.com/v3/#client-errors). `interceptObject()` in `RequestType` gives us a chance to determine if the response is an error. If the response is an error, you can create custom error object from the response object and throw the error in `interceptObject()`.

Here is an example of handling [GitHub API errors](https://developer.github.com/v3/#client-errors):

```swift
// https://developer.github.com/v3/#client-errors
struct GitHubError {
    let message: String

    init(object: AnyObject) {
        message = object["message"] as? String ?? "Unknown error occurred"
    }
}

extension GitHubRequestType {
    func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        guard (200..<300).contains(URLResponse.statusCode) else {
            throw GitHubError(object: AnyObject)
        }

        return object
    }
}
```

The custom error you throw in `interceptObject()` can be retrieved from call-site as `.Failure(.ResponseError(GitHubError))`.

```swift
let request = SomeGitHubRequest()

Session.sendRequest(request) { result in
    switch result {
    case .Success(let response):
        print(response)

    case .Failure(let error):
        printSessionTaskError(error)
    }
}

func printSessionTaskError(error: SessionTaskError) {
    switch sessionTaskError {
    case .ResponseError(let error as GitHubError):
        print(error.message) // Prints message from GitHub API

    case .ConnectionError(let error):
        print("Connection error: \(error.localizedDescription)")

    default:
        print("System error :bow:")
    }
}
```
