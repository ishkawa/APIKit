APIKit
======

[![Circle CI](https://img.shields.io/circleci/project/ishkawa/APIKit.svg?style=flat)](https://circleci.com/gh/ishkawa/APIKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

protocol set for building type safe web API client in Swift.

## Example

### Sending request

```swift
// parameters of request are validated by type system of Swift
let request = GitHub.Request.SearchRepositories(query: "APIKit", sort: .Stars)

GitHub.sendRequest(request) { response in
    // no optional bindings are required to get response and error (thanks to LlamaKit.Result)
    switch response {
    case .Success(let box):
        // type of response is inferred from type of request
        self.repositories = box.unbox
        self.tableView?.reloadData()
        
    case .Failure(let box):
        let alertController = UIAlertController(title: "Error", message: box.unbox.localizedDescription, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
```

### Defining request

```swift
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
    
    var URLRequest: NSURLRequest {
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
```

See [GitHub](https://github.com/ishkawa/APIKit/blob/master/DemoApp/GitHub.swift) and [GitHubRequests](https://github.com/ishkawa/APIKit/blob/master/DemoApp/GitHubRequests.swift) for more details.

## License

Copyright (c) 2015 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
