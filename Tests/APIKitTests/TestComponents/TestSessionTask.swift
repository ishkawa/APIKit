import Foundation
import APIKit

class TestSessionTask: SessionTask {

    var handler: (Data?, URLResponse?, Error?) -> Void
    var progressHandler: (Int64, Int64, Int64) -> Void
    var cancelled = false

    init(progressHandler: @escaping  (Int64, Int64, Int64) -> Void, handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.handler = handler
        self.progressHandler = progressHandler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
