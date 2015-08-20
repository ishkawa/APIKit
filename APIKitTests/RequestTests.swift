import XCTest
import OHHTTPStubs
import APIKit

class RequestTests: XCTestCase {
    struct SearchRequest: MockAPIRequest {
        let query: String
        
        // MARK: Request
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

    func testURLQueryParameterEncoding() {
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
}
