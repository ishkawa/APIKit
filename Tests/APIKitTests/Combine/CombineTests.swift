#if canImport(Combine)

import Foundation
import XCTest
import Combine
import APIKit

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
final class CombineTests: XCTestCase {

    var adapter: TestSessionAdapter!
    var session: Session!
    var cancellables: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        adapter = TestSessionAdapter()
        session = Session(adapter: adapter)
    }

    override func tearDown() {
        super.tearDown()
        cancellables = []
    }

    func testSuccess() {
        let dictionary = ["key": "value"]
        adapter.data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sessionTaskPublisher(for: request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    XCTFail()
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { response in
                XCTAssertEqual((response as? [String: String])?["key"], "value")
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testParseDataError() {
        adapter.data = "{\"broken\": \"json}".data(using: .utf8, allowLossyConversion: false)

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sessionTaskPublisher(for: request)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion, case .responseError(let responseError as NSError) = error {
                    XCTAssertEqual(responseError.domain, NSCocoaErrorDomain)
                    XCTAssertEqual(responseError.code, 3840)
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }, receiveValue: { response in
                XCTFail()
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testCancel() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        let cancellable = session.sessionTaskPublisher(for: request)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion, case .connectionError(let connectionError as NSError) = error {
                    XCTAssertEqual(connectionError.code, 0)
                    expectation.fulfill()
                } else {
                    XCTFail()
                }
            }, receiveValue: { response in
                XCTFail()
            })

        cancellable.cancel()

        waitForExpectations(timeout: 1.0, handler: nil)
    }

}

#endif
