import Foundation
import APIKit
import XCTest
import OHHTTPStubs
import Result

class SessionTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()

        adapter = TestSessionAdapter()
        session = Session(adapter: adapter)
    }

    func testSuccess() {
        let dictionary = ["key": "value"]
        adapter.data = try! JSONSerialization.data(withJSONObject: dictionary, options: [])
        
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { response in
            switch response {
            case .success(let dictionary):
                XCTAssertEqual(dictionary["key"], "value")

            case .failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Response error
    func testParseDataError() {
        adapter.data = "{\"broken\": \"json}".data(using: .utf8, allowLossyConversion: false)

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .failure(let error) = result,
               case .ResponseError(let responseError as NSError) = error {
                XCTAssertEqual(responseError.domain, NSCocoaErrorDomain)
                XCTAssertEqual(responseError.code, 3840)
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUnacceptableStatusCodeError() {
        adapter.URLResponse = HTTPURLResponse(url: NSURL(string: "")! as URL, statusCode: 400, httpVersion: nil, headerFields: nil)

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .failure(let error) = result,
               case .ResponseError(let responseError as ResponseError) = error,
               case .UnacceptableStatusCode(let statusCode) = responseError {
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testNonHTTPURLResponseError() {
        adapter.URLResponse = URLResponse()

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .failure(let error) = result,
               case .ResponseError(let responseError as ResponseError) = error,
               case .NonHTTPURLResponse(let URLResponse) = responseError {
                XCTAssert(URLResponse === self.adapter.URLResponse)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Request error
    func testRequestError() {
        struct Error: Swift.Error {}

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest() { urlRequest in
            throw Error()
        }
        
        session.sendRequest(request) { result in
            if case .failure(let error) = result,
               case .RequestError(let requestError) = error {
                XCTAssert(requestError is Error)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)

    }

    // MARK: Cancel
    func testCancel() {
        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .failure(let error) = result,
               case .ConnectionError(let connectionError as NSError) = error {
                XCTAssertEqual(connectionError.code, 0)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testCancelFilter() {
        let successExpectation = expectation(description: "wait for response")
        let successRequest = TestRequest(path: "/success")

        session.sendRequest(successRequest) { result in
            if case .failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectation(description: "wait for response")
        let failureRequest = TestRequest(path: "/failure")

        session.sendRequest(failureRequest) { result in
            if case .success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self) { request in
            return request.path == failureRequest.path
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    struct AnotherTestRequest: RequestType {
        typealias Response = Void

        var baseUrl: URL {
            return URL(string: "https://example.com")!
        }

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/"
        }

        func responseFromObject(_ object: AnyObject, urlResponse: HTTPURLResponse) throws -> Response {
            return ()
        }
    }

    func testCancelOtherRequestType() {
        let successExpectation = expectation(description: "wait for response")
        let successRequest = AnotherTestRequest()

        session.sendRequest(successRequest) { result in
            if case .failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectation(description: "wait for response")
        let failureRequest = TestRequest()

        session.sendRequest(failureRequest) { result in
            if case .success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Class methods
    func testSharedSession() {
        XCTAssert(Session.sharedSession === Session.sharedSession)
    }

    func testSubclassClassMethods() {
        class SessionSubclass: Session {
            static let testSesssion = SessionSubclass(adapter: TestSessionAdapter())

            var functionCallFlags = [String: Bool]()

            override class var sharedSession: Session {
                return testSesssion
            }

            private override func sendRequest<Request : RequestType>(_ request: Request, callbackQueue: CallbackQueue?, handler: (Result<Request.Response, SessionTaskError>) -> Void) -> SessionTaskType? {
                functionCallFlags[(#function)] = true
                return super.sendRequest(request)
            }

            private override func cancelRequest<Request : RequestType>(_ requestType: Request.Type, passingTest test: (Request) -> Bool) {
                functionCallFlags[(#function)] = true
            }
        }

        let testSession = SessionSubclass.testSesssion
        SessionSubclass.sendRequest(TestRequest())
        SessionSubclass.cancelRequest(TestRequest.self)

        XCTAssertEqual(testSession.functionCallFlags["sendRequest(_:callbackQueue:handler:)"], true)
        XCTAssertEqual(testSession.functionCallFlags["cancelRequest(_:passingTest:)"], true)
    }
}
