import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    
    var handler: (NSData?, NSURLResponse?, ErrorType?) -> Void
    var cancelled = false

    init(handler: (NSData?, NSURLResponse?, ErrorType?) -> Void) {
        self.handler = handler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
