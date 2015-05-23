import Foundation
import APIKit
import XCTest
import Assertions
import OHHTTPStubs

class APITests: XCTestCase {
    class MockAPI: API {
        override class var baseURL: NSURL {
            return NSURL(string: "https://api.github.com")!
        }
        
        override class func responseErrorFromObject(object: AnyObject) -> NSError {
            return NSError(domain: "MockAPIErrorDomain", code: 10000, userInfo: nil)
        }
        
        class Endpoint {
            class Get: Request {
                typealias Response = [String: AnyObject]
                
                var URLRequest: NSURLRequest? {
                    return MockAPI.URLRequest(method: .GET, path: "/")
                }
                
                class func responseFromObject(object: AnyObject) -> Response? {
                    return object as? [String: AnyObject]
                }
            }
        }
    }
    
    class AnotherMockAPI: API {
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }
    
    // MARK: - integration tests
    func testSuccess() {
        let dictionary = ["key": "value"]
        let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)!
        
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { (response, status) in
            switch response {
            case .Success(let box):
                assert(box.value, ==, dictionary)
                
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
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { response,status in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let box):
                let error = box.value
                assertEqual(error.domain, error.domain)
                assertEqual(error.code, error.code)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testFailureOfResponseStatusCode() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            let data = NSJSONSerialization.dataWithJSONObject([:], options: nil, error: nil)!
            return OHHTTPStubsResponse(data: data, statusCode: 400, headers: nil)
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { response,status in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let box):
                let error = box.value
                assertEqual(error.domain, "MockAPIErrorDomain")
                assertEqual(error.code, 10000)
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
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { response,status in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let box):
                let error = box.value
                assert(error.domain, ==, NSCocoaErrorDomain)
                assertEqual(error.code, 3840)
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
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { response,status in
            switch response {
            case .Success:
                XCTFail()
                
            case .Failure(let box):
                let error = box.value
                assert(error.domain, ==, NSURLErrorDomain)
                assertEqual(error.code, NSURLErrorCancelled)
            }
            
            expectation.fulfill()
        }
        
        MockAPI.cancelRequest(MockAPI.Endpoint.Get.self)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSuccessIfCancelingTestReturnsFalse() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            return true
        }, withStubResponse: { request in
            let data = NSJSONSerialization.dataWithJSONObject([:], options: nil, error: nil)!
            let response = OHHTTPStubsResponse(data: data, statusCode: 200, headers: nil)
            response.requestTime = 0.1
            response.responseTime = 0.1
            return response
        })
        
        let expectation = expectationWithDescription("wait for response")
        let request = MockAPI.Endpoint.Get()
        
        MockAPI.sendRequest(request) { response, status in
            switch response {
            case .Success:
                if status != 200 {
                    XCTFail()
                }
                break
                
            case .Failure(let box):
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        MockAPI.cancelRequest(MockAPI.Endpoint.Get.self) { request in
            return false
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
