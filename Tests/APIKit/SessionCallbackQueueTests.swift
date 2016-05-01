import Foundation
import APIKit
import XCTest
import OHHTTPStubs

class SessionCallbackQueueTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        adapter = TestSessionAdapter()
        adapter.data = try! NSJSONSerialization.dataWithJSONObject(["key": "value"], options: [])

        session = Session(adapter: adapter, callbackQueue: .Main)
    }

    func testMain() {
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .Main) { result in
            XCTAssert(NSThread.isMainThread())
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testSessionQueue() {
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .SessionQueue) { result in
            // This depends on implementation of TestSessionAdapter
            XCTAssert(NSThread.isMainThread())
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testOperationQueue() {
        let operationQueue = NSOperationQueue()
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .OperationQueue(operationQueue)) { result in
            XCTAssertEqual(NSOperationQueue.currentQueue(), operationQueue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testDispatchQueue() {
        let dispatchQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: .DispatchQueue(dispatchQueue)) { result in
            // There is no way to test current dispatch queue.
            XCTAssert(!NSThread.isMainThread())
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: Test Session.callbackQueue
    func testImplicitSessionCallbackQueue() {
        let operationQueue = NSOperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .OperationQueue(operationQueue))

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request) { result in
            XCTAssertEqual(NSOperationQueue.currentQueue(), operationQueue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testExplicitSessionCallbackQueue() {
        let operationQueue = NSOperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .OperationQueue(operationQueue))

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request, callbackQueue: nil) { result in
            XCTAssertEqual(NSOperationQueue.currentQueue(), operationQueue)
            expectation.fulfill()
        }

        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
