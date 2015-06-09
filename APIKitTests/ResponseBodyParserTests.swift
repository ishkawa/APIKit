import Foundation
import APIKit
import Result
import XCTest

class ResponseBodyParserTests: XCTestCase {
    func testJSONAcceptHeader() {
        let parser = ResponseBodyParser.JSON(readingOptions: nil)
        XCTAssert(parser.acceptHeader == "application/json")
    }
    
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: nil)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.value as? [String: Int]
            XCTAssert(dictionary?["foo"] == 1)
            XCTAssert(dictionary?["bar"] == 2)
            XCTAssert(dictionary?["baz"] == 3)

        case .Failure:
            XCTFail()
        }
    }

    func testJSONFailure() {
        let string = "{\"foo\": 1, \"bar\": 2, \" 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: nil)

        switch parser.parseData(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            let error = box.value
            XCTAssert(error.domain == NSCocoaErrorDomain)
            XCTAssert(error.code == 3840)
        }
    }

    func testURLAcceptHeader() {
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)
        XCTAssert(parser.acceptHeader == "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.value as? [String: String]
            XCTAssert(dictionary?["foo"] == "1")
            XCTAssert(dictionary?["bar"] == "2")
            XCTAssert(dictionary?["baz"] == "3")

        case .Failure:
            XCTFail()
        }
    }
    
    func testCustomAcceptHeader() {
        let parser = ResponseBodyParser.Custom(acceptHeader: "foo", parseData: { d in .success(d) })
        XCTAssert(parser.acceptHeader == "foo")
    }

    func testCustomSuccess() {
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "", parseData: { data in
            return .success(["foo": 1])
        })

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.value as? [String: Int]
            XCTAssert(dictionary?["foo"] == 1)

        case .Failure:
            XCTFail()
        }
    }

    func testCustomFailure() {
        let expectedError = NSError()
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "", parseData: { data in
            return .failure(expectedError)
        })

        switch parser.parseData(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            XCTAssert(box.value == expectedError)
        }
    }
}
