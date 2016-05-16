import Foundation
import APIKit

class TestSessionAdapter: SessionAdapterType {
    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: NSError?

    var tasks = [TestSessionTask]()
    var responseTime = NSTimeInterval(0.05)

    init(data: NSData? = NSData(), URLResponse: NSURLResponse? = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil), error: NSError? = nil) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error
    }

    func createTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType {
        let task = TestSessionTask(data: data, URLResponse: URLResponse, error: error) { [weak self] task in
            if let index = self?.tasks.indexOf({ $0 === task }) {
                self?.tasks.removeAtIndex(index)
            }
        }

        tasks.append(task)

        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(responseTime * NSTimeInterval(NSEC_PER_SEC)))
        let queue = dispatch_get_main_queue()

        dispatch_after(time, queue) { [weak self] in
            handler(task.data, task.URLResponse, task.error)

            if let index = self?.tasks.indexOf({ $0 === task }) {
                self?.tasks.removeAtIndex(index)
            }
        }

        return task
    }

    func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        handler(tasks.map { $0 })
    }
}
