import Foundation
import APIKit
import XCTest
import OHHTTPStubs

protocol MockAPIRequest: Request {
}

extension MockAPIRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }

    func buildErrorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType? {
        return MockAPI.Errors.Mock
    }
}

class MockAPI: API {
    enum Errors: ErrorType {
        case Mock
    }

    struct GetRoot: MockAPIRequest {
        typealias Response = [String: AnyObject]

        var method: APIKit.Method {
            return .GET
        }

        var path: String {
            return "/"
        }

        func buildResponseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
            guard let response = object as? [String: AnyObject] else {
                throw Errors.Mock
            }

            return response
        }
    }
}

class APITests: XCTestCase {

    class AnotherMockAPI: API {
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
        let request = MockAPI.GetRoot()
        
        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success(let dictionary):
                XCTAssert(dictionary["key"] as? String == "value")

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
        let request = MockAPI.GetRoot()

        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ConnectionError(let error):
                    XCTAssert(error.domain == NSURLErrorDomain)

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
        let request = MockAPI.GetRoot()
        
        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .UnacceptableStatusCode(let error):
                    XCTAssert(error is MockAPI.Errors)

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
        let request = MockAPI.GetRoot()
        
        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .CannotBuildResponseObject(let error as NSError):
                    XCTAssert(error.domain == NSCocoaErrorDomain)
                    XCTAssert(error.code == 3840)

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
        let request = MockAPI.GetRoot()
        
        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let error):
                switch error {
                case .ConnectionError(let error):
                    XCTAssert(error.domain == NSURLErrorDomain)
                    XCTAssert(error.code == NSURLErrorCancelled)

                default:
                    XCTFail()
                }
            }
            
            expectation.fulfill()
        }
        
        MockAPI.cancelRequest(MockAPI.GetRoot.self)
        
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
        let request = MockAPI.GetRoot()
        
        MockAPI.sendRequest(request) { response in
            switch response {
            case .Success:
                break
                
            case .Failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        MockAPI.cancelRequest(MockAPI.GetRoot.self) { request in
            return false
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
