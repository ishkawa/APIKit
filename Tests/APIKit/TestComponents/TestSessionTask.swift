import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    enum Error: ErrorType {
        case Cancelled
    }

    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: NSError?
    var handler: (TestSessionTask, Bool) -> Void

    var responseTime = NSTimeInterval(0.05)

    init(data: NSData?, URLResponse: NSURLResponse?, error: NSError?, handler: (TestSessionTask, Bool) -> Void) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error
        self.handler = handler
    }

    func resume() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(responseTime * NSTimeInterval(NSEC_PER_SEC)))
        let queue = dispatch_get_main_queue()

        dispatch_after(time, queue) {
            self.handler(self, true)
        }
    }

    func cancel() {
        error = Error.Cancelled as NSError
        handler(self, false)
    }
}
