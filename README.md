APIKit
======

[![Circle CI](https://img.shields.io/circleci/project/ishkawa/APIKit/master.svg?style=flat)](https://circleci.com/gh/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

APIKit is a networking library for building type safe web API client in Swift.
By taking advantage of Swift, APIKit provides following features: 

- Enumerate all endpoints in nested class.
- Validate request parameters by type.
- Associate type of response with type of request using generics.
- Return model object or `NSError` as a non-optional value in handler (thanks to [LlamaKit](https://github.com/LlamaKit/LlamaKit)).

so you can:

- Call API without looking API documentation.
- Receive response as a non-optional model object.
- Write exhaustive completion handler easily.

See the demo code below to understand good points of APIKit.

```swift
// parameters of request are validated by type system of Swift
let request = GitHub.Endpoint.SearchRepositories(query: "APIKit", sort: .Stars)

GitHub.sendRequest(request) { response in
    // no optional bindings are required to get response and error (thanks to LlamaKit.Result)
    switch response {
    case .Success(let box):
        // type of response is inferred from type of request
        self.repositories = box.unbox
        self.tableView?.reloadData()

    case .Failure(let box):
        // if request fails, value in box is a NSError
        println(box.unbox)
    }
}
```


## Requirements

- Swift 1.2
- iOS 8.0 or later (if you use Carthage), iOS 7.0 if you copy sources
- Mac OS 10.9 or later

If you want to use APIKit with Swift 1.1, try [0.6.0](https://github.com/ishkawa/APIKit/releases/tag/0.6.0).

## Installation

You have 3 choices. If your app supports iOS 7.0, you can only choose copying source files.

#### 1. Using Carthage (Recommended)

- Insert `github "ishkawa/APIKit"` to your Cartfile.
- Run `carthage update`.

#### 2. Using CocoaPods

- Insert `use_frameworks!` to your Podfile.
- Insert `pod "APIKit"` to your Podfile.
- Run `pod install`.

#### 3. Copying source files

- Clone this repository: `git clone --recursive https://github.com/ishkawa/APIKit.git`.
- Copy `APIKit/*.swift` and `Carthage/Checkouts/LlamaKit/LlamaKit/*.swift` to your project.


## Usage

1. Create subclass of `API` that represents target web API.
2. Set base URL by overriding `baseURL`.
3. Set encoding of request body by overriding `requestBodyBuilder`.
4. Set encoding of response body by overriding `responseBodyParser`.
5. Define request classes that conforms to `Request` for each endpoints.

### Example

```swift
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
        class SearchRepositories: Request {
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

        // define other requests here
    }
}
```

### Sending request

```swift
let request = GitHub.Endpoint.SearchRepositories(query: "APIKit", sort: .Stars)

GitHub.sendRequest(request) { response in
    switch response {
    case .Success(let box):
        // type of `box.unbox` is `[Repository]` (model object)
        
    case .Failure(let box):
        // type of `box.unbox` is `NSError`
    }
}
```

### Canceling request

```swift
GitHub.cancelRequest(GitHub.Endpoint.SearchRepositories.self)
```

If you want to filter requests to be cancelled, add closure that identifies the request shoule be cancelled or not.

```swift
GitHub.cancelRequest(GitHub.Endpoint.SearchRepositories.self) { request in
    return request.query == "APIKit"
}
```

## Advanced usage

### Creating NSError from response object

You can create detailed error using response object from Web API.
For example, [GitHub API](https://developer.github.com/v3/#client-errors) returns error like this:

```json
{
    "message": "Validation Failed"
}
```

To create error that contains `message` in response, override `API.responseErrorFromObject(object:)` and return `NSError` using response object.

```swift
public override class func responseErrorFromObject(object: AnyObject) -> NSError {
    if let message = (object as? NSDictionary)?["message"] as? String {
        let userInfo = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "YourAppAPIErrorDomain", code: 40000, userInfo: userInfo)
    } else {
        let userInfo = [NSLocalizedDescriptionKey: "unresolved error occurred."]
        return NSError(domain: "YourAppAPIErrorDomain", code: 40001, userInfo: userInfo)
    }
}
```

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
