import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    enum Error: ErrorType {
        case Cancelled
    }

    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: NSError?
    var cancelHandler: (TestSessionTask) -> Void

    init(data: NSData?, URLResponse: NSURLResponse?, error: NSError?, cancelHandler: (TestSessionTask) -> Void) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error
        self.cancelHandler = cancelHandler
    }

    func cancel() {
        error = Error.Cancelled as NSError
        cancelHandler(self)
    }
}
