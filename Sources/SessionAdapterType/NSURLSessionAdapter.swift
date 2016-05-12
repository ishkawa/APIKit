import Foundation

extension NSURLSessionTask: SessionTaskType {

}

private var dataTaskResponseBufferKey = 0
private var uploadTaskInputStreamKey = 0
private var taskAssociatedObjectCompletionHandlerKey = 0

/// `NSURLSessionAdapter` connects `NSURLSession` with `Session`.
///
/// If you want to add custom behavior of `NSURLSession` by implementing delegate methods defined in
/// `NSURLSessionDelegate` or related protocols, define a subclass of `NSURLSessionAdapter` and implment
/// delegate methods that you want to implement. Since `NSURLSessionAdapter` also implements delegate methods
/// `URLSession(_:task: didCompleteWithError:)` and `URLSession(_:dataTask:didReceiveData:)`, you have to call
/// `super` in these methods if you implement them.
public class NSURLSessionAdapter: NSObject, SessionAdapterType, NSURLSessionDelegate, NSURLSessionTaskDelegate {
    /// The undelying `NSURLSession` instance.
    public var URLSession: NSURLSession!
    
    /// Returns `NSURLSessionAdapter` initialized with `NSURLSessionConfiguration`.
    public init(configuration: NSURLSessionConfiguration) {
        super.init()
        self.URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    public func createTaskWithRequest<Request : RequestType>(request: Request, handler: (NSData?, NSURLResponse?, ErrorType?) -> Void) throws -> SessionTaskType {
        let URLRequest = NSMutableURLRequest()

        if let bodyParameters = request.bodyParameters {
            switch try bodyParameters.buildEntity() {
            case .Data(let data):
                URLRequest.HTTPBody = data

            case .InputStream(let inputStream):
                URLRequest.HTTPBodyStream = inputStream
            }
        }

        URLRequest.URL = try request.buildURL()
        URLRequest.HTTPMethod = request.method.rawValue

        request.headerFields.forEach { key, value in
            URLRequest.setValue(value, forHTTPHeaderField: key)
        }

        let task: NSURLSessionTask
        switch try request.bodyParameters?.buildEntity() {
        case .Data(let data)?:
            task = URLSession.uploadTaskWithRequest(URLRequest, fromData: data)

        case .InputStream(let inputStream)?:
            task = URLSession.uploadTaskWithStreamedRequest(URLRequest)
            setInputStream(inputStream, forTask: task)

        default:
            task = URLSession.dataTaskWithRequest(URLRequest)
        }

        setBuffer(NSMutableData(), forTask: task)
        setHandler(handler, forTask: task)

        return task
    }

    public func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [NSURLSessionTask]
                + uploadTasks as [NSURLSessionTask]
                + downloadTasks as [NSURLSessionTask]

            handler(allTasks.map { $0 })
        }
    }

    // MARK: Associated objects
    private func setBuffer(buffer: NSMutableData, forTask task: NSURLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, buffer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func bufferForTask(task: NSURLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
    }

    private func setInputStream(inputStream: NSInputStream, forTask task: NSURLSessionTask) {
        objc_setAssociatedObject(task, &uploadTaskInputStreamKey, inputStream, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func inputStreamForTask(task: NSURLSessionTask) -> NSInputStream? {
        return objc_getAssociatedObject(task, &uploadTaskInputStreamKey) as? NSInputStream
    }

    private func setHandler(handler: (NSData?, NSURLResponse?, NSError?) -> Void, forTask task: NSURLSessionTask) {
        objc_setAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey, Box(handler), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func handlerForTask(task: NSURLSessionTask) -> ((NSData?, NSURLResponse?, NSError?) -> Void)? {
        return (objc_getAssociatedObject(task, &taskAssociatedObjectCompletionHandlerKey) as? Box<(NSData?, NSURLResponse?, NSError?) -> Void>)?.value
    }

    // MARK: NSURLSessionTaskDelegate
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError connectionError: NSError?) {
        handlerForTask(task)?(bufferForTask(task), task.response, connectionError)
    }

    public func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
        completionHandler(inputStreamForTask(task))
    }

    // MARK: NSURLSessionDataDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        bufferForTask(dataTask)?.appendData(data)
    }
}
