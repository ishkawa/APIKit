APIKit
======

[![Circle CI](https://img.shields.io/circleci/project/ishkawa/APIKit/master.svg?style=flat)](https://circleci.com/gh/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A networking library for building type safe web API client in Swift.

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

- iOS 7.0 or later
- Mac OS 10.9 or later


## Installation

You have 2 choices. If your app supports iOS 7.0, you can only choose copying source files.

#### 1. Using Carthage (Recommended)

- Install [Carthage](https://github.com/Carthage/Carthage).
- Insert `github "ishkawa/APIKit"` to your Cartfile.
- Run `carthage update`.


#### 2. Copying source files

- Clone this repository: `git clone --recursive https://github.com/ishkawa/APIKit.git`.
- Copy `APIKit/*.swift` and `Carthage/Checkouts/LlamaKit/LlamaKit/*.swift` to your project.


## Usage

1. Create subclass of `API` that represents target web API.
2. Set base URL by overriding `baseURL()`.
3. Set encoding of request body by overriding `requestBodyBuilder()`.
4. Set encoding of response body by overriding `responseBodyParser()`.
5. Define request classes that conforms to `Request` for each endpoints.

### Example

```swift
class GitHub: API {
    override class func baseURL() -> NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    override class func requestBodyBuilder() -> RequestBodyBuilder {
        return .JSON(writingOptions: nil)
    }

    override class func responseBodyParser() -> ResponseBodyParser {
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

            func responseFromObject(object: AnyObject) -> Response? {
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
        class SearchUsers: Request {
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

            func responseFromObject(object: AnyObject) -> Response? {
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
```

## Advanced usage


### NSURLSessionDelegate

APIKit creates singleton instances for each subclasses of API and set them as delegates of NSURLSession,
so you can add following features by implementing delegate methods.

- Hook events of NSURLSession
- Handle authentication challenges
- Convert task to NSURLSessionDownloadTask

#### Overriding delegate methods implemented by API

API class also uses delegate methods of NSURLSession to implement wrapper of NSURLSession, so you should call super if you override following methods.

- `func URLSession(session:task:didCompleteWithError:)`
- `func URLSession(session:dataTask:didReceiveData:)`


## License

Copyright (c) 2015 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
