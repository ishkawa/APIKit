# Getting started

1. [Library overview](#library-overview)
2. [Defining request type](#defining-request-type)
3. [Sending request](#sending-request)
4. [Canceling request](#canceling-request)

## Library overview

The main units of APIKit are `Request` protocol and `Session` class. `Request` has properties that represent components of HTTP/HTTPS request. `Session` receives an instance of a type that conforms to `Request`, then it returns the result of the request. The response type is inferred from the request type, so response type changes depending on the request type.

```swift
// SearchRepositoriesRequest conforms to Request protocol.
let request = SearchRepositoriesRequest(query: "swift")

// Session receives an instance of a type that conforms to Request.
Session.send(request) { result in
    switch result {
    case .success(let response):
        // Type of `response` is `[Repository]`,
        // which is inferred from `SearchRepositoriesRequest`.
        print(response)

    case .failure(let error):
        self.printError(error)
    }
}
```

## Defining request type

`Request` defines several properties and methods. Since many of them have default implementation, components which is necessary for conforming to `Request` are following 5 components:

- `typealias Response`
- `var baseURL: URL`
- `var method: HTTPMethod`
- `var path: String`
- `func response(from object: Any, urlResponse: HTTPURLResponse) throws -> RateLimit`

```swift
struct RateLimitRequest: Request {
    typealias Response = RateLimit

    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/rate_limit"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> RateLimit {
        return try RateLimit(object: object)
    }
}

struct RateLimit {
    let limit: Int
    let remaining: Int

    init(object: Any) throws {
        guard let dictionary = object as? [String: Any],
              let rateDictionary = dictionary["rate"] as? [String: Any],
              let limit = rateDictionary["limit"] as? Int,
              let remaining = rateDictionary["remaining"] as? Int else {
            throw ResponseError.unexpectedObject(object)
        }

        self.limit = limit
        self.remaining = remaining
    }
}
```

## Sending request

`Session.send(_:handler:)` is a method to send a request that conforms to `Request`. The result of the request is expressed as `Result<Request.Response, SessionTaskError>`. `Result<T, Error>` is from [antitypical/Result](https://github.com/antitypical/Result), which is generic enumeration with 2 cases `.success` and `.failure`. `Request` is a type parameter of `Session.send(_:handler:)` which conforms to `Request` protocol.

For example, when `Session.send(_:handler:)` receives `RateLimitRequest` as a type parameter `Request`, the result type will be `Result<RateLimit, SessionTaskError>`.

```swift
let request = RateLimitRequest()

Session.send(request) { result in
    switch result {
    case .success(let rateLimit):
        // Type of `rateLimit` is inferred as `RateLimit`,
        // which is also known as `RateLimitRequest.Response`.
        print("limit: \(rateLimit.limit)")
        print("remaining: \(rateLimit.remaining)")

    case .failure(let error):
        print("error: \(error)")
    }
}
```

`SessionTaskError` is an error enumeration that has 3 cases:

- `connectionError`: Error of networking backend stack.
- `requestError`: Error while creating `URLRequest` from `Request`.
- `responseError`: Error while creating `Request.Response` from `(Data, URLResponse)`.

## Canceling request

`Session.cancelRequests(with:passingTest:)` also has a type parameter `Request` that conforms to `Request`. This method takes 2 parameters `requestType: Request.Type` and `test: Request -> Bool`. `requestType` is a type of request to cancel, and `test` is a closure that determines if request should be cancelled.

For example, when `Session.cancelRequests(with:passingTest:)` receives `RateLimitRequest.Type` and `{ request in true }` as parameters, `Session` finds all session tasks associated with `RateLimitRequest` in the backend queue. Next, execute `{ request in true }` for each session tasks and cancel the task if it returns `true`. Since `{ request in true }` always returns `true`, all request associated with `RateLimitRequest` will be cancelled.

```swift
Session.cancelRequests(with: RateLimitRequest.self) { request in
    return true
}
```

`Session.cancelRequests(with:passingTest:)` has default parameter for predicate closure, so you can omit the predicate closure like below:

```swift
Session.cancelRequests(with: RateLimitRequest.self)
```
