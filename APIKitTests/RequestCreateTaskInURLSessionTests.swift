import XCTest
import OHHTTPStubs
import APIKit

class RequestCreateTaskInURLSessionTest: XCTestCase {
    // MARK: - Sample requests for tests
    struct Request: RequestType {
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
    
    func testCreateTaskInURLSession() {
        // MARK: - baseURL = https://example.com
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com", path: "/foo/bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar//")
        )
        
        // MARK: - baseURL = https://example.com/
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api/
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com/api/", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        //　MARK: - baseURL = https://example.com///
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/bar")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/bar", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/bar/")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar/")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "/foo/bar/", parameters: ["p": 1])?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com////foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            Request(baseURL: "https://example.com///", path: "foo//bar//")?.buildURLRequest().value?.URL,
            NSURL(string: "https://example.com///foo//bar//")
        )
    }
}
