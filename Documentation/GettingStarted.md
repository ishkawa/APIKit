# Getting started

1. [Library overview](#library-overview)
2. [Defining request type](#defining-request-type)
3. [Sending request](#sending-request)
4. [Canceling request](#canceling-request)

## Library overview

The main units of APIKit are `RequestType` protocol and `Session` class. `RequestType` has properties that represent components of HTTP/HTTPS request. `Session` receives an instance of a type that conforms to `RequestType`, then it returns the result of the request. The response type is inferred from the request type, so response type changes depending on the request type.

```swift
// SearchRepositoriesRequest conforms to RequestType
let request = SearchRepositoriesRequest(query: "APIKit", sort: .Stars)

// Session receives an instance of a type that conforms to RequestType.
Session.sendRequest(request) { result in
    switch result {
    case .Success(let repositories):
        // Type of `repositories` is `[Repository]`,
        // which is inferred from `SearchRepositoriesRequest`.
        print(repositories)

    case .Failure(let error):
        print(error)
    }
}
```

## Defining request type

`RequestType` defines several properties and methods. Since many of them have default implementation, components which is necessary for conforming to `RequestType` are following 5 components:

- `typealias Response`
- `var baseURL: NSURL`
- `var method: Method`
- `var path: String`
- `func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response`

```swift
struct RateLimitRequest: GitHubRequestType {
    typealias Response = RateLimit

    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/rate_limit"
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let dictionary = object as? [String: AnyObject] else {
            return nil
        }

        guard let rateLimit = RateLimit(dictionary: dictionary) else {
            return nil
        }

        return rateLimit
    }
}
```

## Sending request

`Session.sendRequest()` is a method to send a request that conforms to `RequestType`. The result of the request is expressed as `Result<Request.Response, SessionTaskError>`. `Result<T, Error>` is from [antitypical/Result](https://github.com/antitypical/Result), which is generic enumeration with 2 cases `.Success` and `.Failure`. `Request` is a type parameter of `Session.sendRequest()` which conforms to `RequestType`.

For example, when `Session.sendRequest()` receives `RateLimitRequest` as a type parameter `Request`, the result type will be `Result<RateLimit, SessionTaskError>`.

```swift
let request = RateLimitRequest()

Session.sendRequest(request) { result in
    switch result {
    case .Success(let rateLimit):
        // Type of `rateLimit` is inferred as `RateLimit`,
        // which is also known as `RateLimitRequest.Response`.
        print("count: \(rateLimit.count)")
        print("resetDate: \(rateLimit.resetDate)")

    case .Failure(let error):
        print("error: \(error)")
    }
}
```

`SessionTaskError` is an error enumeration that has 3 cases:

- `ConnectionError`: Error of networking backend stack.
- `RequestError`: Error while creating `NSURLRequest` from `Request`.
- `ResponseError`: Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.

## Canceling request

`Session.cancelRequest()` also has a type parameter `Request` that conforms to `RequestType`. `Session.cancelRequest()` takes 2 parameters `requestType: Request.Type` and `test: Request-> Bool`. `requestType` is a type of request to cancel, and `test` is a closure that determines if request should be cancelled.

For example, when `Session.cancel()` receives `RateLimitRequest.Type` and `{ request in true }` as parameters, `Session` finds all session tasks associated with `RateLimitRequest` in the backend queue. Next, execute `{ request in true }` for each session tasks and cancel the task if it returns `true`. Since `{ request in true }` always returns `true`, all request associated with `RateLimitRequest` will be cancelled.

```swift
Session.cancelRequest(RateLimitRequest.Type) { request in
    return true
}
```

`Session.cancelRequest` has default parameter for predicate closure, so you can omit the predicate closure like below:

```swift
Session.cancelRequest(RateLimitRequest.Type)
```
