import Foundation
import XCTest
import APIKit

class URLSessionAdapterSubclassTests: XCTestCase {
    class SessionAdapter: URLSessionAdapter {
        var functionCallFlags = [String: Bool]()

        override func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            functionCallFlags[(#function)] = true
            super.urlSession(session, task: task, didCompleteWithError: error)
        }

        override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            functionCallFlags[(#function)] = true
            super.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }

    var adapter: SessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [HTTPStub.self]

        adapter = SessionAdapter(configuration: configuration)
        session = Session(adapter: adapter)
    }

    func testDelegateMethodCall() {
        let data = "{}".data(using: .utf8)!
        HTTPStub.stubResult = .success(data)

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.send(request) { result in
            if case .failure = result {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)

        XCTAssertEqual(adapter.functionCallFlags["urlSession(_:task:didCompleteWithError:)"], true)
        XCTAssertEqual(adapter.functionCallFlags["urlSession(_:dataTask:didReceive:)"], true)
    }
}
