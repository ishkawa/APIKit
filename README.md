APIKit
======

[![Circle CI](https://img.shields.io/circleci/project/ishkawa/APIKit/master.svg?style=flat)](https://circleci.com/gh/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APIKit is a library for building type safe web API client in Swift.

- Parameters of a request are validated by type system.
- Type of a response is inferred from type of its request.
- A result of request is represented by [Result<Value, Error>](https://github.com/antitypical/Result), which is also known as Either.
- All the endpoints can be enumerated in nested class.

```swift
let request = GitHub.Endpoint.SearchRepositories(query: "APIKit", sort: .Stars)

GitHub.sendRequest(request) { result in
    switch result {
    case .Success(let response):
        self.repositories = response // inferred as [Repository]
        self.tableView.reloadData()

    case .Failure(let error):
        println(error)
    }
}
```


## Requirements

- Swift 2
- iOS 8.0 or later
- Mac OS 10.9 or later

If you want to use APIKit with Swift 1.2, try [0.8.2](https://github.com/ishkawa/APIKit/releases/tag/0.8.2).

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

- Insert `github "ishkawa/APIKit"` to your Cartfile.
- Run `carthage update`.
- Link your app with `APIKit.framework` and `Result.framework` in `Carthage/Checkouts`.

#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod "APIKit"` to your Podfile.
- Run `pod install`.

## Usage

1. Create a request protocol that inherits `Request` protocol.
2. Add `baseURL` variable in extension of request protocol.
3. Create a API class that inherits `API` class.
4. Define request types that conforms to request protocol in `Endpoint` class in API class.
    1. Create a type that represents a endpoint of the web API.
    2. Assign type that represents response object to `Response` typealiase.
    3. Add `method` and `path` variables.
    4. Implement `buildResponseFromObject(_:URLResponse:)` to build `Response` from raw object, which may be an array or a dictionary.

```swift
protocol GitHubRequest: Request {
}

extension GitHubRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

class GitHubAPI: API {
}

extension GitHubAPI.Endpoint {
    struct GetRateLimit: GitHubRequest {
        typealiase Response = RateLimit

        var method: Method {
            return .GET
        }

        var path: String {
            return "/rate_limit"
        }

        func buildResponseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
            guard let dictionary = object as? [String: AnyObject] else {
                throw SomeError
            }

            guard let rateLimit = RateLimit(dictionary) else {
                throw SomeError
            }

            return rateLimit
        }
    }
}

struct RateLimit {
    let count: Int
    let resetDate: NSDate

    init?(dictionary: [String: AnyObject]) {
        ...
    }
}
```

### Sending request

```swift
let request = GitHubAPI.Endpoint.GetRateLimit()

GitHubAPI.sendRequest(request) { result in
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
GitHub.cancelRequest(GitHub.Endpoint.RateLimit)
```

If you want to filter requests to be cancelled, add closure that identifies the request shoule be cancelled or not.

```swift
GitHub.cancelRequest(GitHub.Endpoint.SearchRepositories.self) { request in
    return request.query == "APIKit"
}
```

### Configuring request

#### Setting parameters
#### Setting serializer of a request
#### Setting serializer of a response
#### Adding fields to HTTP header of a request
#### Building NSURLRequest manually

### Configuring response

#### Setting acceptable status code

```swift
var acceptableStatusCodes: Set<Int> {
  return Set(200)
}
```

#### Building custom error from a response

You can create detailed error using response object from Web API.
For example, [GitHub API](https://developer.github.com/v3/#client-errors) returns error like this:

```json
{
    "message": "Validation Failed"
}
```

To create error that contains `message` in response, override `API.responseErrorFromObject(object:)` and return `NSError` using response object.

```swift
func buildErrorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> ErrorType {
    guard let dictionary = object as? [String: AnyObject] else {
        throw SomeError
    }

    guard let message = dictionary["message"] as? String else {
        throw SomeError
    }

    return GitHubError(message: message)
}
```

## Practical Example

### Pagination

```swift
let request = SomeAPI.Endpoint.SomePaginatedRequest(page: 1)

SomeAPI.sendRequest(request) { result in
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
    var results: Array<T>
    var nextPage: Int { get }
    var hasNext: Bool { get }

    init(results: Array<T>, URLResponse: NSHTTPURLResponse) {
        self.results = results
        self.nextPage = /* get nextPage from `Link` field of URLResponse */
        self.hasNext = /* get hasNext from `Link` field of URLResponse */
    }
}

struct SomePaginatedRequest: Request {
    typealias Response = PaginatedResponse<Some>

    var method: Method {
        return .GET
    }

    var path: String {
        return "/paginated"
    }

    let page: Int

    static func buildResponseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        guard let dictionaries = object as? [[String: AnyObject]] else {
            throw SomeError
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

## Advanced usage

### NSURLSessionDelegate

You can add custom behaviors of `NSURLSession` by following steps:

1. Create a subclass of `URLSessionDelegate` (e.g. `MyAPIURLSessionDelegate`).
2. Implement additional delegate methods in it.
3. Override `defaultURLSession` of `API` and return `NSURLSession` that has `MyURLSessionDelegate` as its delegate.

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
