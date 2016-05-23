import Foundation
import APIKit
import XCTest
import OHHTTPStubs

class SessionTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        adapter = TestSessionAdapter()
        session = Session(adapter: adapter)
    }

    func testSuccess() {
        let dictionary = ["key": "value"]
        adapter.data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { response in
            switch response {
            case .Success(let dictionary):
                XCTAssertEqual(dictionary["key"], "value")

            case .Failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: Response error
    func testParseDataError() {
        adapter.data = "{\"broken\": \"json}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ResponseError(let responseError as NSError) = error {
                XCTAssertEqual(responseError.domain, NSCocoaErrorDomain)
                XCTAssertEqual(responseError.code, 3840)
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testUnacceptableStatusCodeError() {
        adapter.URLResponse = NSHTTPURLResponse(URL: NSURL(), statusCode: 400, HTTPVersion: nil, headerFields: nil)

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ResponseError(let responseError as ResponseError) = error,
               case .UnacceptableStatusCode(let statusCode) = responseError {
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: Cancel
    func testCancel() {
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ConnectionError(let connectionError as NSError) = error {
                XCTAssertEqual(connectionError.code, 0)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testCancelFilter() {
        let successExpectation = expectationWithDescription("wait for response")
        let successRequest = TestRequest(path: "/success")

        session.sendRequest(successRequest) { result in
            if case .Failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectationWithDescription("wait for response")
        let failureRequest = TestRequest(path: "/failure")

        session.sendRequest(failureRequest) { result in
            if case .Success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self) { request in
            return request.path == failureRequest.path
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
