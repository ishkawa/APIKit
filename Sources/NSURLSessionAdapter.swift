import Foundation

extension NSURLSessionTask: SessionTaskType {

}

public class NSURLSessionAdapter: SessionAdapterType {
    public let URLSession: NSURLSession
    
    public init(URLSession: NSURLSession) {
        self.URLSession = URLSession
    }

    public func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType {
        let task = URLSession.dataTaskWithRequest(URLRequest, completionHandler: handler)
        task.resume()

        return task
    }

    public func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let allTasks = dataTasks as [NSURLSessionTask]
                + uploadTasks as [NSURLSessionTask]
                + downloadTasks as [NSURLSessionTask]

            handler(allTasks.map {$0})
        }
    }
}
