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
        adapter.data = try! NSJSONSerialization.dataWithJSONObject(dictionary, options: [])
        
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { response in
            switch response {
            case .Success(let dictionary):
                XCTAssertEqual(dictionary["key"], "value")

            case .Failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: Response error
    func testParseDataError() {
        adapter.data = "{\"broken\": \"json}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ResponseError(let responseError as NSError) = error {
                XCTAssertEqual(responseError.domain, NSCocoaErrorDomain)
                XCTAssertEqual(responseError.code, 3840)
            } else {
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testUnacceptableStatusCodeError() {
        adapter.URLResponse = NSHTTPURLResponse(URL: NSURL(), statusCode: 400, HTTPVersion: nil, headerFields: nil)

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ResponseError(let responseError as ResponseError) = error,
               case .UnacceptableStatusCode(let statusCode) = responseError {
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testNonHTTPURLResponseError() {
        adapter.URLResponse = NSURLResponse()

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ResponseError(let responseError as ResponseError) = error,
               case .NonHTTPURLResponse(let URLResponse) = responseError {
                XCTAssert(URLResponse === self.adapter.URLResponse)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    // MARK: Request error
    func testRequestError() {
        struct Error: ErrorType {}

        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest() { URLRequest in
            throw Error()
        }
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .RequestError(let requestError) = error {
                XCTAssert(requestError is Error)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)

    }

    // MARK: Cancel
    func testCancel() {
        let expectation = expectationWithDescription("wait for response")
        let request = TestRequest()
        
        session.sendRequest(request) { result in
            if case .Failure(let error) = result,
               case .ConnectionError(let connectionError as NSError) = error {
                XCTAssertEqual(connectionError.code, 0)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self)
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    func testCancelFilter() {
        let successExpectation = expectationWithDescription("wait for response")
        let successRequest = TestRequest(path: "/success")

        session.sendRequest(successRequest) { result in
            if case .Failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectationWithDescription("wait for response")
        let failureRequest = TestRequest(path: "/failure")

        session.sendRequest(failureRequest) { result in
            if case .Success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self) { request in
            return request.path == failureRequest.path
        }
        
        waitForExpectationsWithTimeout(1.0, handler: nil)
    }

    struct AnotherTestRequest: RequestType {
        typealias Response = Void

        var baseURL: NSURL {
            return NSURL(string: "https://example.com")!
        }

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/"
        }

        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
            return ()
        }
    }

    func testCancelOtherRequestType() {
        let successExpectation = expectationWithDescription("wait for response")
        let successRequest = AnotherTestRequest()

        session.sendRequest(successRequest) { result in
            if case .Failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectationWithDescription("wait for response")
        let failureRequest = TestRequest()

        session.sendRequest(failureRequest) { result in
            if case .Success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequest(TestRequest.self)

        waitForExpectationsWithTimeout(1.0, handler: nil)
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

            private override func sendRequest<Request : RequestType>(request: Request, callbackQueue: CallbackQueue?, handler: (Result<Request.Response, SessionTaskError>) -> Void) -> SessionTaskType? {
                functionCallFlags[(#function)] = true
                return super.sendRequest(request)
            }

            private override func cancelRequest<Request : RequestType>(requestType: Request.Type, passingTest test: Request -> Bool) {
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
