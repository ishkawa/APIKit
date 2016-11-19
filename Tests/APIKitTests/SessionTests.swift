import Foundation
import APIKit
import XCTest
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
        
        session.send(request) { response in
            switch response {
            case .success(let dictionary):
                XCTAssertEqual((dictionary as? [String: String])?["key"], "value")

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
        
        session.send(request) { result in
            if case .failure(let error) = result,
               case .responseError(let responseError as NSError) = error {
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
        adapter.urlResponse = HTTPURLResponse(url: NSURL(string: "")! as URL, statusCode: 400, httpVersion: nil, headerFields: nil)

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.send(request) { result in
            if case .failure(let error) = result,
               case .responseError(let responseError as ResponseError) = error,
               case .unacceptableStatusCode(let statusCode) = responseError {
                XCTAssertEqual(statusCode, 400)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testNonHTTPURLResponseError() {
        adapter.urlResponse = URLResponse()

        let expectation = self.expectation(description: "wait for response")
        let request = TestRequest()
        
        session.send(request) { result in
            if case .failure(let error) = result,
               case .responseError(let responseError as ResponseError) = error,
               case .nonHTTPURLResponse(let urlResponse) = responseError {
                XCTAssert(urlResponse === self.adapter.urlResponse)
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
        
        session.send(request) { result in
            if case .failure(let error) = result,
               case .requestError(let requestError) = error {
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
        
        session.send(request) { result in
            if case .failure(let error) = result,
               case .connectionError(let connectionError as NSError) = error {
                XCTAssertEqual(connectionError.code, 0)
            } else {
                XCTFail()
            }

            expectation.fulfill()
        }
        
        session.cancelRequests(with: TestRequest.self)
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testCancelFilter() {
        let successExpectation = expectation(description: "wait for response")
        let successRequest = TestRequest(path: "/success")

        session.send(successRequest) { result in
            if case .failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectation(description: "wait for response")
        let failureRequest = TestRequest(path: "/failure")

        session.send(failureRequest) { result in
            if case .success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequests(with: TestRequest.self) { request in
            return request.path == failureRequest.path
        }
        
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    struct AnotherTestRequest: Request {
        typealias Response = Void

        var baseURL: URL {
            return URL(string: "https://example.com")!
        }

        var method: HTTPMethod {
            return .get
        }

        var path: String {
            return "/"
        }

        func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
            return ()
        }
    }

    func testCancelOtherRequest() {
        let successExpectation = expectation(description: "wait for response")
        let successRequest = AnotherTestRequest()

        session.send(successRequest) { result in
            if case .failure = result {
                XCTFail()
            }

            successExpectation.fulfill()
        }

        let failureExpectation = expectation(description: "wait for response")
        let failureRequest = TestRequest()

        session.send(failureRequest) { result in
            if case .success = result {
                XCTFail()
            }

            failureExpectation.fulfill()
        }
        
        session.cancelRequests(with: TestRequest.self)

        waitForExpectations(timeout: 1.0, handler: nil)
    }

    // MARK: Class methods
    func testSharedSession() {
        XCTAssert(Session.shared === Session.shared)
    }

    func testSubclassClassMethods() {
        class SessionSubclass: Session {
            static let testSesssion = SessionSubclass(adapter: TestSessionAdapter())

            var functionCallFlags = [String: Bool]()

            override class var shared: Session {
                return testSesssion
            }

            override func send<Request : APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue?, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void) -> SessionTask? {
                functionCallFlags[(#function)] = true
                return super.send(request)
            }

            override func cancelRequests<Request : APIKit.Request>(with requestType: Request.Type, passingTest test: @escaping (Request) -> Bool) {
                functionCallFlags[(#function)] = true
            }
        }

        let testSession = SessionSubclass.testSesssion
        SessionSubclass.send(TestRequest())
        SessionSubclass.cancelRequests(with: TestRequest.self)

        XCTAssertEqual(testSession.functionCallFlags["send(_:callbackQueue:handler:)"], true)
        XCTAssertEqual(testSession.functionCallFlags["cancelRequests(with:passingTest:)"], true)
    }
}
