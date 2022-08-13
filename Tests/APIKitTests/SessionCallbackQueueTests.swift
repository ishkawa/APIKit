import Foundation
import APIKit
import XCTest

class SessionCallbackQueueTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUpWithError() throws {
        try super.setUpWithError()

        adapter = TestSessionAdapter()
        adapter.data = try XCTUnwrap(JSONSerialization.data(withJSONObject: ["key": "value"], options: []))

        session = Session(adapter: adapter, callbackQueue: .main)
    }

    func testMain() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, callbackQueue: .main, completionHandler: { result in
            XCTAssert(Thread.isMainThread)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testSessionQueue() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, callbackQueue: .sessionQueue, completionHandler: { result in
            // This depends on implementation of TestSessionAdapter
            XCTAssertTrue(Thread.isMainThread)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testOperationQueue() {
        let operationQueue = OperationQueue()
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, callbackQueue: .operationQueue(operationQueue), completionHandler: { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testDispatchQueue() {
        let dispatchQueue = DispatchQueue.global(qos: .default)
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, callbackQueue: .dispatchQueue(dispatchQueue), completionHandler: { result in
            // There is no way to test current dispatch queue.
            XCTAssertFalse(Thread.isMainThread)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Test Session.callbackQueue
    func testImplicitSessionCallbackQueue() {
        let operationQueue = OperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .operationQueue(operationQueue))

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, completionHandler: { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testExplicitSessionCallbackQueue() {
        let operationQueue = OperationQueue()
        let session = Session(adapter: adapter, callbackQueue: .operationQueue(operationQueue))

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.send(request, callbackQueue: nil, completionHandler: { result in
            XCTAssertEqual(OperationQueue.current, operationQueue)
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
