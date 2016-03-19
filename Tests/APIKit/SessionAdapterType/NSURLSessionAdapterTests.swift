import Foundation
import APIKit
import XCTest
import OHHTTPStubs

protocol MockSessionRequestType: RequestType {
}

extension MockSessionRequestType {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

class NSURLSessionAdapterTests: XCTestCase {
    var session: Session!

    override func setUp() {
        super.setUp()

        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let adapter = NSURLSessionAdapter(configuration: configuration)
        session = Session(adapter: adapter)
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    // MARK: - integration tests
    func testSuccess() {
        let dictionary = ["key": "value"]
        let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
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
    
    func testConnectionError() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(error: error)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()

        session.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ConnectionError(let error):
                    XCTAssertEqual(error.domain, NSURLErrorDomain)

                default:
                    XCTFail()
                }
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }    
}