import Foundation

/// `SessionTaskType` protocol represents a task for a request.
public protocol SessionTaskType: class {
    func cancel()
}

/// `SessionAdapterType` protocol provides interface to connect lower level networking backend with `Session`.
/// APIKit provides `NSURLSessionAdapter`, which conforms to `SessionAdapterType`, to connect `NSURLSession`
/// with `Session`.
public protocol SessionAdapterType {
    /// Returns resumed instance that conforms to `SessionTaskType`. `handler` must be called after success or failure.
    func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType

    /// Collects tasks from backend networking stack. `handler` must be called after collecting.
    func getTasksWithHandler(handler: [SessionTaskType] -> Void)
}
