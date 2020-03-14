import Foundation
import APIKit

class TestSessionTask: SessionTask {

    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var progressHandler: (Int64, Int64, Int64) -> Void
    var cancelled = false

    init(progressHandler: @escaping  (Int64, Int64, Int64) -> Void, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completionHandler = completionHandler
        self.progressHandler = progressHandler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
