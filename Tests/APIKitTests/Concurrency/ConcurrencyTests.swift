#if compiler(>=5.6.0) && canImport(_Concurrency)

import XCTest
import APIKit

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
final class ConcurrencyTests: XCTestCase {
    var adapter: TestSessionAdapter!
    var session: Session!

    override func setUp() {
        super.setUp()
        adapter = TestSessionAdapter()
        session = Session(adapter: adapter)
    }

    func testSuccess() async throws {
        let dictionary = ["key": "value"]
        adapter.data = try XCTUnwrap(JSONSerialization.data(withJSONObject: dictionary, options: []))

        let request = TestRequest()
        let value = try await session.response(for: request)
        XCTAssertEqual((value as? [String: String])?["key"], "value")
    }

    func testParseDataError() async throws {
        adapter.data = "{\"broken\": \"json}".data(using: .utf8, allowLossyConversion: false)

        let request = TestRequest()
        do {
            _ = try await session.response(for: request)
            XCTFail()
        } catch {
            let sessionError = try XCTUnwrap(error as? SessionTaskError)
            if case .responseError(let responseError as NSError) = sessionError {
                XCTAssertEqual(responseError.domain, NSCocoaErrorDomain)
                XCTAssertEqual(responseError.code, 3840)
            } else {
                XCTFail()
            }
        }
    }

    func testCancel() async throws {
        let request = TestRequest()

        let task = Task {
            do {
                _ = try await session.response(for: request)
                XCTFail()
            } catch  {
                let sessionError = try XCTUnwrap(error as? SessionTaskError)
                if case .connectionError(let connectionError as NSError) = sessionError {
                    XCTAssertEqual(connectionError.code, 0)
                    XCTAssertTrue(Task.isCancelled)
                } else {
                    XCTFail()
                }
            }
        }
        task.cancel()
        _ = try await task.value

        XCTAssertTrue(task.isCancelled)
    }
}

#endif
