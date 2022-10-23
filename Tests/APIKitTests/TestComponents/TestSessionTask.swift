import Foundation
import APIKit

class TestSessionTask: SessionTask {

    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var uploadProgressHandler: Session.ProgressHandler
    var downloadProgressHandler: Session.ProgressHandler
    var cancelled = false

    init(uploadProgressHandler: @escaping Session.ProgressHandler, downloadProgressHandler: @escaping Session.ProgressHandler, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completionHandler = completionHandler
        self.uploadProgressHandler = uploadProgressHandler
        self.downloadProgressHandler = downloadProgressHandler
    }

    func resume() {
    }

    func cancel() {
        cancelled = true
    }
}
