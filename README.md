APIKit
======

protocol set for building type safe web API client in Swift.

## Example

```swift
let request = GitHub.Request.SearchRepositories(query: "APIKit")

GitHub.sendRequest(request) { response in
    switch response {
    case .Success(let box):
        self.repositories = box.unbox // type of response object is inferred by request
        
    case .Failure(let box):
        let alertController = UIAlertController(title: "Error", message: box.unbox.localizedDescription, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(action)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
```

See [GitHub](https://github.com/ishkawa/APIKit/blob/master/DemoApp/GitHub.swift) and [GitHubRequests](https://github.com/ishkawa/APIKit/blob/master/DemoApp/GitHubRequests.swift) for more details.

## License

Copyright (c) 2015 Yosuke Ishikawa

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
