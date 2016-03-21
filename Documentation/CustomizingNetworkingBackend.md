# Customizing Networking Backend

APIKit uses `NSURLSession` as networking backend by default. Since `Session` has abstraction layer of backend called `SessionAdapterType`, you can change the backend of `Session` like below:

- Third party HTTP client like [Alamofire](https://github.com/Alamofire/Alamofire)
- Mock backend like [`TestSessionAdapter`](../Tests/APIKit/TestComponents/TestSessionAdapter.swift)
- `NSURLSession` with custom configuration and delegate

Demo implementation of Alamofire adapter is available [here](https://github.com/ishkawa/APIKit-AlamofireAdapter).

## SessionAdapterType

`SessionAdapterType` provides an interface to get `(NSData?, NSURLResponse?, NSError?)` from `NSURLRequest` and returns `SessionTaskType` for cancellation.

```swift
public protocol SessionAdapterType {
    func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType
    func getTasksWithHandler(handler: [SessionTaskType] -> Void)
}

public protocol SessionTaskType: class {
    func cancel()
}
```


## How Session works with SessionAdapterType

`Session` takes an instance of type that conforms `SessionAdapterType` as a parameter of initializer.

```swift
public class Session {
    public let adapter: SessionAdapterType

    public init(adapter: SessionAdapterType) {
        self.adapter = adapter
    }

    ...
}
```

Once it is initialized with a session adapter, it sends `NSURLRequest` and receives `(NSData?, NSURLResponse?, NSError?)` via the interfaces which are defined in `SessionAdapterType`.

```swift
func sendRequest<T: RequestType>(request: T, handler: (Result<T.Response, APIError>) -> Void = {r in}) -> SessionTaskType? {
    let URLRequest: NSURLRequest = ...
    let task = adapter.resumedTaskWithURLRequest(URLRequest) { data, URLResponse, error in
        ...
    }
}
```
