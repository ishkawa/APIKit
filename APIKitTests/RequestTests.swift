import XCTest
import OHHTTPStubs
import APIKit

class RequestTests: XCTestCase {
    struct SearchRequest: MockAPIRequestType {
        let query: String
        
        // MARK: RequestType
        typealias Response = [String: AnyObject]
        
        var method: HTTPMethod {
            return .GET
        }
        
        var path: String {
            return "/"
        }
        
        var parameters: [String: AnyObject] {
            return [
                "q": query,
            ]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            return object as? [String: AnyObject]
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testJapanesesURLQueryParameterEncoding() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            XCTAssert(request.URL?.query == "q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF")
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil)
        })
        
        let request = SearchRequest(query: "こんにちは")
        let expectation = expectationWithDescription("waiting for the response.")
        
        API.sendRequest(request) { result in
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testSymbolURLQueryParameterEncoding() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            XCTAssert(request.URL?.query == "q=%21%22%23%24%25%26%27%28%290%3D~%7C%60%7B%7D%2A%2B%3C%3E%3F_")
            return true
        }, withStubResponse: { request in
            return OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: nil)
        })
        
        let request = SearchRequest(query: "!\"#$%&'()0=~|`{}*+<>?_")
        let expectation = expectationWithDescription("waiting for the response.")
        
        API.sendRequest(request) { result in
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }
}
