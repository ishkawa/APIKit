import XCTest
import OHHTTPStubs
import APIKit

class RequestCreateTaskInURLSessionTest: XCTestCase {
    
    var session: NSURLSession!
    
    // MARK: - Sample requests for tests
    
    struct SampleRequest: Request {
        typealias Response = [String: AnyObject]
        var b: String = ""
        var p: String = ""
        var m: HTTPMethod = .GET
        var params: [String: AnyObject] = [:]
        
        var baseURL: NSURL { return NSURL(string: b)! }
        var method: HTTPMethod { return m }
        var path: String { return p  }
        var parameters: [String: AnyObject] { return params }
        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? { return nil }
    }
    
    override func setUp() {
        super.setUp()
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.ephemeralSessionConfiguration())
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs()
        self.session = nil
        super.tearDown()
    }
    
    func testCreateTaskInURLSession() {
        
        func assertRequest(sampleRequest: SampleRequest, pattern: String) {
            
            switch sampleRequest.buildURLRequest() {
            case let .Success(URLRequest):
                guard let url = URLRequest.URL else {
                    XCTFail("The created task doesn't have a valid URL: \(URLRequest)")
                    return
                }
                XCTAssertEqual(url.absoluteString, pattern)
                break
            case let .Failure(error):
                XCTFail("\(error)")
                break
            }
            
        }
        
        var sampleRequest: SampleRequest
        
        // MARK: - baseURL = https://example.com
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = ""
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/foo?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com"
        sampleRequest.p = "foo//bar//"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo//bar//")
        
        // MARK: - baseURL = https://example.com/
        
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = ""
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com//")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com//?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com//foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com//foo?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/bar?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/bar/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com//foo/bar/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/"
        sampleRequest.p = "foo//bar//"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/foo//bar//")
        
        // MARK: - baseURL = https://example.com/api
        
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = ""
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api"
        sampleRequest.p = "foo//bar//"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo//bar//")
        
        // MARK: - baseURL = https://example.com/api/
        
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = ""
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api//")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api//?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/bar?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/bar/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com/api//foo/bar/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com/api/"
        sampleRequest.p = "foo//bar//"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com/api/foo//bar//")
        
        //　MARK: - baseURL = https://example.com///
        
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = ""
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com///")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com////")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com////?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com///foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com////foo")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com////foo?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com///foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/bar")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/bar"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/bar?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/bar/")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "/foo/bar/"
        sampleRequest.m = .GET
        sampleRequest.params = ["p": 1]
        assertRequest(sampleRequest, pattern: "https://example.com////foo/bar/?p=1")
        
        sampleRequest = SampleRequest()
        sampleRequest.b = "https://example.com///"
        sampleRequest.p = "foo//bar//"
        sampleRequest.m = .GET
        sampleRequest.params = [:]
        assertRequest(sampleRequest, pattern: "https://example.com///foo//bar//")
    }
}
