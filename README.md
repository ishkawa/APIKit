APIKit
======

[![Build Status](https://travis-ci.org/ishkawa/APIKit.svg?branch=master)](https://travis-ci.org/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APIKit is a library for building type-safe web API client in Swift.

- Parameters of a request are validated by type-system.
- Type of a response is inferred from the type of its request.
- A result of a request is represented by [Result<Value, Error>](https://github.com/antitypical/Result), which is also known as Either.

```swift
let request = GetSearchRepositoriesRequest(query: "APIKit", sort: .Stars)

Session.sendRequest(request) { result in
    switch result {
    case .Success(let response):
        self.repositories = response // inferred as [Repository]
        self.tableView.reloadData()

    case .Failure(let error):
        print(error)
    }
}
```

## Requirements

- Swift 2.1
- Mac OS 10.9 or later
- iOS 8.0 or later
- watchOS 2.0 or later
- tvOS 9.0 or later

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

- Insert `github "ishkawa/APIKit" ~> 1.1.2` to your Cartfile.
- Run `carthage update`.
- Link your app with `APIKit.framework` and `Result.framework` in `Carthage/Checkouts`.

#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'APIKit', '~> 1.1.2'` to your Podfile.
- Run `pod install`.

## Usage

1. Create a request protocol that inherits `RequestType` protocol.
2. Add `baseURL` property in the extension of the request protocol.
3. Define request types that conform to request protocol.
    1. Create a type that represents request of the web API.
    2. Assign type that represents a response object to `Response` typealiase.
    3. Add `method` and `path` variables.
    4. Implement `responseFromObject(_:URLResponse:)` to build `Response` from a raw object, which may be an array or a dictionary.

```swift
protocol GitHubRequestType: RequestType {

}

extension GitHubRequestType {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

struct GetRateLimitRequest: GitHubRequestType {
    typealias Response = RateLimit

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

struct RateLimit {
    let count: Int
    let resetDate: NSDate

    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }

        guard let resetDateString = dictionary["rate"]?["reset"] as? NSTimeInterval else {
            return nil
        }

        self.count = count
        self.resetDate = NSDate(timeIntervalSince1970: resetDateString)
    }
}
```

### Sending request

```swift
let request = GetRateLimitRequest()

Session.sendRequest(request) { result in
    switch result {
    case .Success(let rateLimit):
        print("count: \(rateLimit.count)")
        print("resetDate: \(rateLimit.resetDate)")

    case .Failure(let error):
        print("error: \(error)")
    }
}
```

### Canceling request

```swift
Session.cancelRequest(GetRateLimitRequest.self)
```

If you want to filter requests to be cancelled, add closure that identifies the request should be cancelled or not.

```swift
Session.cancelRequest(GetSearchRepositoriesRequest.self) { request in
    return request.query == "APIKit"
}
```

### Configuring request

APIKit uses following 4 properties in `RequestType` when build `NSURLRequest`.

```swift
var baseURL: NSURL
var method: HTTPMethod
var path: String
var parameters: [String: AnyObject]
```

`parameters` will be converted into query parameter if `method` is one of `.GET`, `.HEAD` and `.DELETE`.
Otherwise, it will be serialized by `requestBodyBuilder` and set to `HTTPBody` of `NSURLRequest`.
You can pass `NSNull()` as a value for nullable keys if you'd like to preserve the keys when its value is absent.

#### Configuring format of HTTP body

APIKit uses `requestBodyBuilder` when it serialize parameter into HTTP body of a request, and it uses `responseBodyParser` when it deserialize an object from HTTP body of a response. Default format of the body of request and response is JSON.

```swift
var requestBodyBuilder: RequestBodyBuilder
var responseBodyParser: ResponseBodyParser
```

You can specify the format of HTTP body implement this property.

```swift
var requestBodyBuilder: RequestBodyBuilder {
    return .URL(encoding: NSUTF8StringEncoding)
}
```

#### Configuring manually

```
func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
    // You can add any configurations here
}
```

### Configuring response

#### Setting acceptable status code

APIKit decides if a request is succeeded or failed by using `acceptableStatusCodes:`. If it contains the status code of a response, the request is judged as succeeded and `Session` calls `responseFromObject(_:URLResponse:)` to get a model from a raw response. Otherwise, the request is judged as failed and `Session` calls `errorFromObject(_:URLResponse:)` to get an error from a raw response.

```swift
var acceptableStatusCodes: Set<Int> {
    return Set(200..<300)
}
```

#### Building a model from a response

```swift
func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
    guard let dictionary = object as? [String: AnyObject] else {
        return nil
    }

    guard let rateLimit = RateLimit(dictionary: dictionary) else {
        return nil
    }

    return rateLimit
}
```

#### Building an error from a response

For example, [GitHub API](https://developer.github.com/v3/#client-errors) returns an error like this:

```json
{
    "message": "Validation Failed"
}
```

To create error that contains `message` in response, implement `errorFromObject(_:URLResponse:)` and return `ErrorType` using object.

```swift
func errorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType? {
    guard let dictionary = object as? [String: AnyObject] else {
        return nil
    }

    guard let message = dictionary["message"] as? String else {
        return nil
    }

    return GitHubError(message: message)
}
```

## Practical Example

### Authorization

```swift
var GithubAccessToken: String?

protocol GitHubRequest: RequestType {
    var authenticate: Bool { get }
}

extension GitHubRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    var authenticate: Bool {
        return true
    }

    func configureURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest {
        if authenticate {
            guard let accessToken = GitHubAccessToken else {
                throw APIKitError.CannotBuildURLRequest
            }

            URLRequest.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return URLRequest
    }
}
```

### Pagination

```swift
let request = GetSomePaginatedRequest(page: 1)

Session.sendRequest(request) { result in
    switch result {
    case .Success(let response):
        print("results: \(response.results)")
        print("nextPage: \(response.nextPage)")
        print("hasNext: \(response.hasNext)")

    case .Failure(let error):
        print("error: \(error)")
    }
}
```

```swift
struct PaginatedResponse<T> {
    var results: [T]
    var nextPage: Int { get }
    var hasNext: Bool { get }

    init(results: [T], URLResponse: NSHTTPURLResponse) {
        self.results = results
        self.nextPage = /* get nextPage from `Link` field of URLResponse */
        self.hasNext = /* get hasNext from `Link` field of URLResponse */
    }
}

struct SomePaginatedRequest: RequestType {
    typealias Response = PaginatedResponse<Some>

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/paginated"
    }

    let page: Int

    static func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        guard let dictionaries = object as? [[String: AnyObject]] else {
            return nil
        }

        var somes = [Some]()
        for dictionary in dictionaries {
            if let some = Some(dictionary: dictionary) {
                somes.append()
            }
        }

        return PaginatedResponse(results: somes, URLResponse: URLResponse)
    }
}
```

### Combination with Himotoki

[Himotoki](https://github.com/ikesyo/Himotoki) is a type-safe JSON decoding library that can be combined with APIKit. It makes implementing `responseFromObject(_:URLResponse:)` very easy. If your model type conforms to `Decodable` protocol in Himotoki, a request can be defined like below:

```swift
// model type
struct RateLimit: Decodable {
    let count: Int
    let resetUNIXTime: NSTimeInterval

    static func decode(e: Extractor) throws -> RateLimit {
        return try build(self.init)(
            e.value(["rate", "limit"]),
            e.value(["rate", "reset"])
        )
    }
}

// request type
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/rate_limit"
    }

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
        return try? decode(object) // get Response from AnyObject using Himotoki
    }
}
```

Additionally, you can provide default implementation of `responseFromObject(_:URLResponse:)` if `Response` typealias of a request type conforms to `Decodable`.

```swift
extension GitHubRequest where Self.Response: Decodable, Self.Response == Self.Response.DecodedType {
    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Self.Response? {
        return try? decode(object)
    }
}
```

As a result, you can omit implementing `responseFromObject(_:URLResponse:)` in the definition of a request type.

```swift
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/rate_limit"
    }
}
```

See [this gist post](https://gist.github.com/ishkawa/59dd67042289ee4b5cab) for more practical example.

## Advanced usage

### NSURLSessionDelegate

You can add custom behaviors of `NSURLSession` by following steps:

1. Create a subclass of `URLSessionDelegate` (e.g. `MyURLSessionDelegate`).
2. Implement additional delegate methods in it.
3. Create a new `Session` instance that has `MyURLSessionDelegate` as a delegate of `NSURLSession`.

```swift
let session = Session(URLSession: NSURLSession(
    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
    delegate: MyURLSessionDelegate(),
    delegateQueue: nil)
)
```

This can add following features:

- Hook events of NSURLSession
- Handle authentication challenges
- Convert a data task to NSURLSessionDownloadTask

NOTE: `URLSessionDelegate` also implements delegate methods of `NSURLSession` to implement wrapper of `NSURLSession`, so you should call super if you override following methods.

- `func URLSession(_:task:didCompleteWithError:)`
- `func URLSession(_:dataTask:didReceiveData:)`
- `func URLSession(_:dataTask:didBecomeDownloadTask:)`


## License

Copyright (c) 2015 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
