# Customizing Networking Backend

APIKit uses `URLSession` as networking backend by default. Since `Session` has abstraction layer of backend called `SessionAdapter`, you can change the backend of `Session` like below:

- Third party HTTP client like [Alamofire](https://github.com/Alamofire/Alamofire)
- Mock backend like [`TestSessionAdapter`](../Tests/APIKit/TestComponents/TestSessionAdapter.swift)
- `URLSession` with custom configuration and delegate

Demo implementation of Alamofire adapter is available [here](https://github.com/ishkawa/APIKit-AlamofireAdapter).

## SessionAdapter

`SessionAdapter` provides an interface to get `(Data?, URLResponse?, Error?)` from `URLRequest` and returns `SessionTask` for cancellation.

```swift
public protocol SessionAdapter {
    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask
    func getTasks(with handler: @escaping ([SessionTask]) -> Void)
}

public protocol SessionTask: class {
    func resume()
    func cancel()
}
```


## How Session works with SessionAdapter

`Session` takes an instance of type that conforms `SessionAdapter` as a parameter of initializer.

```swift
open class Session {
    public let adapter: SessionAdapter
    public let callbackQueue: CallbackQueue

    public init(adapter: SessionAdapter, callbackQueue: CallbackQueue = .main) {
        self.adapter = adapter
        self.callbackQueue = callbackQueue
    }

    ...
}
```

Once it is initialized with a session adapter, it sends `URLRequest` and receives `(Data?, URLResponse?, Error?)` via the interfaces which are defined in `SessionAdapter`.

```swift
open func send<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
    let urlRequest: URLRequest = ...
    let task = adapter.createTask(with: urlRequest) { data, urlResponse, error in
        ...
    }

    task.resume()

    return task
}
```
