import Foundation
import APIKit
import XCTest
import OHHTTPStubs

class URLSessionAdapterTests: XCTestCase {
    var session: Session!

    override func setUp() {
        super.setUp()

        let configuration = URLSessionConfiguration.default
        let adapter = URLSessionAdapter(configuration: configuration)
        session = Session(adapter: adapter)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    // MARK: - integration tests
    func testSuccess() {
        let dictionary = ["key": "value"]
        let data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { response in
            switch response {
            case .success(let dictionary):
                XCTAssertEqual(dictionary["key"], "value")

            case .failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testConnectionError() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(error: error)
        })
        
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request) { response in
            switch response {
            case .success:
                XCTFail()
                
            case .failure(let error):
                switch error {
                case .ConnectionError(let error as NSError):
                    XCTAssertEqual(error.domain, NSURLErrorDomain)

                default:
                    XCTFail()
                }
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }

    func testCancel() {
        let data = try! JSONSerialization.data(withJSONObject: [:], options: [])
        
        OHHTTPStubs.stubRequests(passingTest: { request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil).responseTime(1.0)
        })
        
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()

        session.sendRequest(request) { result in
            guard case .failure(let error) = result,
                  case .ConnectionError(let connectionError as NSError) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(connectionError.code, NSURLErrorCancelled)

            expectation.fulfill()
        }

        DispatchQueue.main.async {
            self.session.cancelRequest(TestRequest.self)
        }

        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
