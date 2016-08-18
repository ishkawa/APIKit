import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    
    var handler: (NSData?, URLResponse?, Error?) -> Void
    var cancelled = false

    init(handler: @escaping (NSData?, URLResponse?, Error?) -> Void) {
        self.handler = handler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
