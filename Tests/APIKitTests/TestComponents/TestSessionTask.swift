import Foundation
import APIKit

class TestSessionTask: SessionTask {

    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var progressHandler: (Progress) -> Void
    var cancelled = false

    init(progressHandler: @escaping  (Progress) -> Void, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completionHandler = completionHandler
        self.progressHandler = progressHandler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
