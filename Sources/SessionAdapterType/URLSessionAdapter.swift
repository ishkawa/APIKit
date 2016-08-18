import Foundation

extension URLSessionTask: SessionTaskType {

}

private var dataTaskResponseBufferKey = 0
private var taskAssociatedObjectCompletionHandlerKey = 0

/// `URLSessionAdapter` connects `URLSession` with `Session`.
///
/// If you want to add custom behavior of `URLSession` by implementing delegate methods defined in
/// `URLSessionDelegate` and related protocols, define a subclass of `URLSessionAdapter` and implment
/// delegate methods that you want to implement. Since `URLSessionAdapter` also implements delegate methods
/// `URLSession(_:task: didCompleteWithError:)` and `URLSession(_:dataTask:didReceiveData:)`, you have to call
/// `super` in these methods if you implement them.
open class URLSessionAdapter: NSObject, SessionAdapterType, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    /// The undelying `URLSession` instance.
    open var urlSession: URLSession!

    /// Returns `URLSessionAdapter` initialized with `URLSessionConfiguration`.
    public init(configuration: URLSessionConfiguration) {
        super.init()
        self.urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    /// Creates `URLSessionDataTask` instance using `dataTaskWithRequest(_:completionHandler:)`.
    open func createTaskWithURLRequest(_ URLRequest: URLRequest, handler: @escaping (NSData?, URLResponse?, Error?) -> Void) -> SessionTaskType {
        let task = urlSession.dataTask(with: URLRequest)

        setBuffer(NSMutableData(), forTask: task)
        setHandler(handler, forTask: task)

        task.resume()

        return task
    }

    /// Aggregates `URLSessionTask` instances in `URLSession` using `getTasksWithCompletionHandler(_:)`.
    open func getTasksWithHandler(_ handler: @escaping ([SessionTaskType]) -> Void) {
        urlSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [URLSessionTask]
                + uploadTasks as [URLSessionTask]
                + downloadTasks as [URLSessionTask]

            handler(allTasks.map { $0 })
        }
    }

    private func setBuffer(_ buffer: NSMutableData, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, buffer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func bufferForTask(_ task: URLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
    }

    private func setHandler(_ handler: (NSData?, URLResponse?, Error?) -> Void, forTask task: URLSessionTask) {
        objc_setAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey, Box(handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func handlerForTask(_ task: URLSessionTask) -> ((NSData?, URLResponse?, Error?) -> Void)? {
        return (objc_getAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey) as? Box<(NSData?, URLResponse?, Error?) -> Void>)?.value
    }

    // MARK: URLSessionTaskDelegate
    open func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        handlerForTask(task)?(bufferForTask(task), task.response, error)
    }

    // MARK: URLSessionDataDelegate
    open func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        bufferForTask(dataTask)?.append(data)
    }
}