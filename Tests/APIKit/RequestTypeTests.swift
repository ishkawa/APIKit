import XCTest
import APIKit

class RequestTypeTests: XCTestCase {
    func testJapanesesQueryParameters() {
        let request = TestRequest(parameters: ["q": "こんにちは"])
        let URL = try? request.buildURL()
        XCTAssertEqual(URL?.query, "q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF")
    }
    
    func testSymbolQueryParameters() {
        let request = TestRequest(parameters: ["q": "!\"#$%&'()0=~|`{}*+<>?/_"])
        let URL = try? request.buildURL()
        XCTAssertEqual(URL?.query, "q=%21%22%23%24%25%26%27%28%290%3D~%7C%60%7B%7D%2A%2B%3C%3E?/_")
    }

    func testNullQueryParameters() {
        let request = TestRequest(parameters: ["null": NSNull()])
        let URL = try? request.buildURL()
        XCTAssertEqual(URL?.query, "null")
    }
    
    func testBuildURL() {
        // MARK: - baseURL = https://example.com
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: ""),
            NSURL(string: "https://example.com")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/"),
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "foo"),
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo", parameters: ["p": 1]),
            NSURL(string: "https://example.com/foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/"),
            NSURL(string: "https://example.com/foo/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "foo/bar"),
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/bar"),
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/bar", parameters: ["p": 1]),
            NSURL(string: "https://example.com/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/bar/"),
            NSURL(string: "https://example.com/foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/bar/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com", path: "/foo/bar//"),
            NSURL(string: "https://example.com/foo/bar//")
        )
        
        // MARK: - baseURL = https://example.com/
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: ""),
            NSURL(string: "https://example.com/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/"),
            NSURL(string: "https://example.com//")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/", parameters: ["p": 1]),
            NSURL(string: "https://example.com//?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "foo"),
            NSURL(string: "https://example.com/foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo"),
            NSURL(string: "https://example.com//foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo", parameters: ["p": 1]),
            NSURL(string: "https://example.com//foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/"),
            NSURL(string: "https://example.com//foo/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/", parameters: ["p": 1]),
            NSURL(string: "https://example.com//foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "foo/bar"),
            NSURL(string: "https://example.com/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/bar"),
            NSURL(string: "https://example.com//foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/bar", parameters: ["p": 1]),
            NSURL(string: "https://example.com//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/bar/"),
            NSURL(string: "https://example.com//foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "/foo/bar/", parameters: ["p": 1]),
            NSURL(string: "https://example.com//foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/", path: "foo//bar//"),
            NSURL(string: "https://example.com/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: ""),
            NSURL(string: "https://example.com/api")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/"),
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "foo"),
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo"),
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api/foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/"),
            NSURL(string: "https://example.com/api/foo/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api/foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "foo/bar"),
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/bar"),
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/bar", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api/foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/bar/"),
            NSURL(string: "https://example.com/api/foo/bar/")
        )

        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "/foo/bar/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api/foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api", path: "foo//bar//"),
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        // MARK: - baseURL = https://example.com/api/
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: ""),
            NSURL(string: "https://example.com/api/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/"),
            NSURL(string: "https://example.com/api//")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api//?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "foo"),
            NSURL(string: "https://example.com/api/foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo"),
            NSURL(string: "https://example.com/api//foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api//foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/"),
            NSURL(string: "https://example.com/api//foo/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api//foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "foo/bar"),
            NSURL(string: "https://example.com/api/foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/bar"),
            NSURL(string: "https://example.com/api//foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/bar", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api//foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/bar/"),
            NSURL(string: "https://example.com/api//foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "/foo/bar/", parameters: ["p": 1]),
            NSURL(string: "https://example.com/api//foo/bar/?p=1")
        )

        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com/api/", path: "foo//bar//"),
            NSURL(string: "https://example.com/api/foo//bar//")
        )
        
        //　MARK: - baseURL = https://example.com///
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: ""),
            NSURL(string: "https://example.com///")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/"),
            NSURL(string: "https://example.com////")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/", parameters: ["p": 1]),
            NSURL(string: "https://example.com////?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "foo"),
            NSURL(string: "https://example.com///foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo"),
            NSURL(string: "https://example.com////foo")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo", parameters: ["p": 1]),
            NSURL(string: "https://example.com////foo?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/"),
            NSURL(string: "https://example.com////foo/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/", parameters: ["p": 1]),
            NSURL(string: "https://example.com////foo/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "foo/bar"),
            NSURL(string: "https://example.com///foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/bar"),
            NSURL(string: "https://example.com////foo/bar")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/bar", parameters: ["p": 1]),
            NSURL(string: "https://example.com////foo/bar?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/bar/"),
            NSURL(string: "https://example.com////foo/bar/")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "/foo/bar/", parameters: ["p": 1]),
            NSURL(string: "https://example.com////foo/bar/?p=1")
        )
        
        XCTAssertEqual(
            TestRequest.URLOf(baseURL: "https://example.com///", path: "foo//bar//"),
            NSURL(string: "https://example.com///foo//bar//")
        )
    }
}
