import Foundation
import Dispatch
import APIKit

class TestSessionAdapter: SessionAdapter {
    enum Error: Swift.Error {
        case cancelled
    }

    var data: Data?
    var urlResponse: URLResponse?
    var error: Error?

    private var tasks = [TestSessionTask]()
    private let timer: DispatchSourceTimer

    init(data: Data? = Data(), urlResponse: URLResponse? = HTTPURLResponse(url: NSURL(string: "")! as URL, statusCode: 200, httpVersion: nil, headerFields: nil), error: Error? = nil) {
        self.data = data
        self.urlResponse = urlResponse
        self.error = error

        timer = DispatchSource.makeTimerSource()
        timer.scheduleRepeating(deadline: .now(), interval: DispatchTimeInterval.milliseconds(10))
        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async { [weak self] in
                self?.executeAllTasks()
            }
        }

        timer.resume()
    }

    deinit {
        timer.cancel()
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

    func createTask(with URLRequest: URLRequest, handler: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> SessionTask {
        let task = TestSessionTask(handler: handler)
        tasks.append(task)

        return task
    }

    func getTasks(with handler: @escaping ([SessionTask]) -> Void) {
        handler(tasks.map { $0 })
    }
}
