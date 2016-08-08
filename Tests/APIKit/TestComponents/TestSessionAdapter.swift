import Foundation
import APIKit

class TestSessionAdapter: SessionAdapterType {
    enum Error: Swift.Error {
        case cancelled
    }

    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    private class Runner {
        weak var adapter: TestSessionAdapter?

        @objc func run() {
            adapter?.executeAllTasks()
        }
    }

    private var tasks = [TestSessionTask]()
    private let runner: Runner
    private let timer: Timer

    init(data: Data? = Data(), urlResponse: URLResponse? = HTTPURLResponse(url: NSURL(string: "")! as URL, statusCode: 200, httpVersion: nil, headerFields: nil), error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error

        self.runner = Runner()
        self.timer = Timer.scheduledTimer(timeInterval: 0.001,
            target: runner,
            selector: #selector(Runner.run),
            userInfo: nil,
            repeats: true)

        self.runner.adapter = self
    }

    func executeAllTasks() {
        for task in tasks {
            if task.cancelled {
                task.handler(nil, nil, Error.cancelled)
            } else {
                task.handler(data, urlResponse, error)
            }
        }

        tasks = []
    }

    func createTaskWithURLRequest(_ URLRequest: URLRequest, handler: (NSData?, URLResponse?, Swift.Error?) -> Void) -> SessionTaskType {
        let task = TestSessionTask(handler: handler)
        tasks.append(task)

        return task
    }

    func getTasksWithHandler(_ handler: ([SessionTaskType]) -> Void) {
        handler(tasks.map { $0 })
    }
}
