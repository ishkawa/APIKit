import Foundation

extension NSURLSessionTask: SessionTaskType {

}

private var dataTaskResponseBufferKey = 0
private var taskAssociatedObjectCompletionHandlerKey = 0

public class NSURLSessionAdapter: NSObject, SessionAdapterType, NSURLSessionDelegate {
    public var URLSession: NSURLSession!
    
    public init(configuration: NSURLSessionConfiguration) {
        super.init()
        self.URLSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }

    public func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType {
        let task = URLSession.dataTaskWithRequest(URLRequest, completionHandler: handler)

        setBuffer(NSMutableData(), forTask: task)
        setHandler(handler, forTask: task)

        task.resume()

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

    private func setBuffer(buffer: NSMutableData, forTask task: NSURLSessionTask) {
        objc_setAssociatedObject(task, &dataTaskResponseBufferKey, NSMutableData(), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func bufferForTask(task: NSURLSessionTask) -> NSMutableData? {
        return objc_getAssociatedObject(task, &dataTaskResponseBufferKey) as? NSMutableData
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

    // MARK: NSURLSessionDataDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        bufferForTask(dataTask)?.appendData(data)
    }
}
