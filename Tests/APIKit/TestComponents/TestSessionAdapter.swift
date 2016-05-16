import Foundation
import APIKit

class TestSessionAdapter: SessionAdapterType {
    enum Error: ErrorType {
        case Cancelled
    }

    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: ErrorType?

    private class Runner {
        weak var adapter: TestSessionAdapter?

        @objc func run() {
            adapter?.executeAllTasks()
        }
    }

    private var tasks = [TestSessionTask]()
    private let runner: Runner
    private let timer: NSTimer

    init(data: NSData? = NSData(), URLResponse: NSURLResponse? = NSHTTPURLResponse(URL: NSURL(), statusCode: 200, HTTPVersion: nil, headerFields: nil), error: NSError? = nil) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error

        self.runner = Runner()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.001,
            target: runner,
            selector: #selector(Runner.run),
            userInfo: nil,
            repeats: true)

        self.runner.adapter = self
    }

    func executeAllTasks() {
        for task in tasks {
            if task.cancelled {
                task.handler(nil, nil, Error.Cancelled)
            } else {
                task.handler(data, URLResponse, error)
            }
        }

        tasks = []
    }

    func createTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, ErrorType?) -> Void) -> SessionTaskType {
        let task = TestSessionTask(handler: handler)
        tasks.append(task)

        return task
    }

    func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        handler(tasks.map { $0 })
    }
}
