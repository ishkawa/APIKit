import Foundation

/// `SessionTask` protocol represents a task for a request.
public protocol SessionTask: AnyObject {
    func resume()
    func cancel()
}

/// `SessionAdapter` protocol provides interface to connect lower level networking backend with `Session`.
/// APIKit provides `URLSessionAdapter`, which conforms to `SessionAdapter`, to connect `URLSession`
/// with `Session`.
public protocol SessionAdapter {
    /// Returns instance that conforms to `SessionTask`. `handler` must be called after success or failure.
    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Error?) -> Void) -> SessionTask

    /// Collects tasks from backend networking stack. `handler` must be called after collecting.
    func getTasks(with handler: @escaping ([SessionTask]) -> Void)
}
