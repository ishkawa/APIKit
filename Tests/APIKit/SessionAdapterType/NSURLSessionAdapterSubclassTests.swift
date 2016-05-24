import Foundation
import XCTest
import OHHTTPStubs
import APIKit

class NSURLSessionAdapterSubclassTests: XCTestCase {
    class SessionAdapter: NSURLSessionAdapter {
        var functionCallFlags = [String: Bool]()

        override func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError connectionError: NSError?) {
            functionCallFlags[(#function)] = true
            super.URLSession(session, task: task, didCompleteWithError: connectionError)
        }

        override func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
            functionCallFlags[(#function)] = true
            super.URLSession(session, dataTask: dataTask, didReceiveData: data)
        }
    }

    var adapter: SessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        adapter = SessionAdapter(configuration: configuration)
        session = Session(adapter: adapter)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testDelegateMethodCall() {
        let data = try! NSJSONSerialization.dataWithJSONObject([:], options: [])
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure = result {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(10.0, handler: nil)

        XCTAssertEqual(adapter.functionCallFlags["URLSession(_:task:didCompleteWithError:)"], true)
        XCTAssertEqual(adapter.functionCallFlags["URLSession(_:dataTask:didReceiveData:)"], true)
    }
}
