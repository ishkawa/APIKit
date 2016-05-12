import Foundation
import APIKit

class TestSessionAdapter: SessionAdapterType {
    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: ErrorType?

    var tasks = [TestSessionTask]()

    init(data: NSData? = NSData(), URLResponse: NSURLResponse? = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil), error: ErrorType? = nil) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error
    }

    func createTaskWithRequest<Request : RequestType>(request: Request, handler: (NSData?, NSURLResponse?, ErrorType?) -> Void) throws -> SessionTaskType {
        let task = TestSessionTask(data: data, URLResponse: URLResponse, error: error) { [weak self] task, completed in
            if completed {
                handler(task.data, task.URLResponse, task.error)
            }

            if let index = self?.tasks.indexOf({ $0 === task }) {
                self?.tasks.removeAtIndex(index)
            }
        }

        tasks.append(task)

        return task
    }

    func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        handler(tasks.map { $0 })
    }
}
