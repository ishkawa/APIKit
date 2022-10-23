import Foundation
import APIKit

class TestSessionAdapter: SessionAdapter {
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
                task.completionHandler(nil, nil, Error.cancelled)
            } else {
                task.uploadProgressHandler(Progress(totalUnitCount: 1))
                task.downloadProgressHandler(Progress(totalUnitCount: 1))
                task.completionHandler(data, urlResponse, error)
            }
        }

        tasks = []
    }

    func createTask(with URLRequest: URLRequest, uploadProgressHandler: @escaping Session.ProgressHandler, downloadProgressHandler: @escaping Session.ProgressHandler, completionHandler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> SessionTask {
        let task = TestSessionTask(uploadProgressHandler: uploadProgressHandler, downloadProgressHandler: downloadProgressHandler, completionHandler: completionHandler)
        tasks.append(task)

        return task
    }

    func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        handler(tasks.map { $0 })
    }
}
