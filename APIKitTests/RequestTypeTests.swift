import XCTest
import OHHTTPStubs
import APIKit

class RequestTypeTests: XCTestCase {
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
                "dummy": NSNull()
            ]
        }
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            return object as? [String: AnyObject]
        }
    }
    
    // request type for URL building tests
    struct ParameterizedRequest: RequestType {
        typealias Response = Void
        
        init?(baseURL: String, path: String, method: HTTPMethod = .GET, parameters: [String: AnyObject] = [:]) {
            guard let baseURL = NSURL(string: baseURL) else {
                return nil
            }
            
            self.baseURL = baseURL
            self.path = path
            self.method = method
            self.parameters = parameters
        }
        
        let baseURL: NSURL
        let method: HTTPMethod
        let path: String
        let parameters: [String: AnyObject]
        
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            abort()
        }
    }

    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        super.tearDown()
    }

    func testJapanesesURLQueryParameterEncoding() {
        OHHTTPStubs.stubRequestsPassingTest({ request in
            XCTAssert(request.URL?.query == "q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF&dummy")
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
            XCTAssert(request.URL?.query == "q=%21%22%23%24%25%26%27%28%290%3D~%7C%60%7B%7D%2A%2B%3C%3E%3F_&dummy")
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
    
    func testBuildURL() {
        // MARK: - baseURL = https://example.com
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com", path: "/foo/bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar//")
        )
        
        // MARK: - baseURL = https://example.com/
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api/
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com/api/", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        //　MARK: - baseURL = https://example.com///
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar/")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            ParameterizedRequest(baseURL: "https://example.com///", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo//bar//")
        )
    }
}
