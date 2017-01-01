import Foundation
import APIKit

class TestSessionTask: SessionTask {
    struct IdGenerator {
        private var currentId = 1
        
        public mutating func next() -> Int {
            currentId += 1
            return currentId
        }
    }
    
    static var idGenerator = IdGenerator()
    
    var taskIdentifier: Int
    var handler: (Data?, URLResponse?, Error?) -> Void
    var cancelled = false

    init(handler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.taskIdentifier = TestSessionTask.idGenerator.next()
        self.handler = handler
    }

    func resume() {

    }

    func cancel() {
        cancelled = true
    }
}
