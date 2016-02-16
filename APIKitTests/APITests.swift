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

class MockSession: Session {
    struct GetRoot: MockSessionRequestType {
        typealias Response = [String: AnyObject]

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/"
        }

        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
            guard let response = object as? [String: AnyObject] else {
                throw FatalError("Invalid object \(object)")
            }
            return response
        }
    }
}

class AnotherMockSession: Session {

}

class APITests: XCTestCase {
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
        let request = MockSession.GetRoot()
        
        MockSession.sendRequest(request) { response in
            switch response {
            case .Success(let dictionary):
                XCTAssertEqual(dictionary["key"] as? String, "value")

            case .Failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureOfConnection() {
        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(error: error)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockSession.GetRoot()

        MockSession.sendRequest(request) { response in
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

    func testFailureOfResponseStatusCode() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            let dictionary: [String: String] = [:]
            let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            return OHHTTPStubsResponse(data: data, statusCode: 400, headers: nil)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockSession.GetRoot()
        
        MockSession.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ResponseError:
                    break

                default:
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureOfDecodingResponseBody() {
        let data = "{\"broken\": \"json}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockSession.GetRoot()
        
        MockSession.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ResponseError(let error as NSError):
                    XCTAssertEqual(error.domain, NSCocoaErrorDomain)
                    XCTAssertEqual(error.code, 3840)

                default:
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    // MARK: cancelling
    func testFailureByCanceling() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            let response = OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil)
            response.requestTime = 0.1
            response.responseTime = 0.1
            return response
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockSession.GetRoot()
        
        MockSession.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ConnectionError(let error):
                    XCTAssertEqual(error.domain, NSURLErrorDomain)
                    XCTAssertEqual(error.code, NSURLErrorCancelled)

                default:
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        MockSession.cancelRequest(MockSession.GetRoot.self)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testSuccessIfCancelingTestReturnsFalse() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            let dictionary: [String: String] = [:]
            let data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
            let response = OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
            response.requestTime = 0.1
            response.responseTime = 0.1
            return response
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockSession.GetRoot()
        
        MockSession.sendRequest(request) { response in
            switch response {
            case .Success:
                break
                
            case .Failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        MockSession.cancelRequest(MockSession.GetRoot.self) { request in
            return false
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
