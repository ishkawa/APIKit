import Foundation
import APIKit
import Assertions
import LlamaKit
import XCTest

class ResponseBodyParserTests: XCTestCase {
    func testJSONAcceptHeader() {
        let parser = ResponseBodyParser.JSON(readingOptions: nil)
        assertEqual(parser.acceptHeader, "application/json")
    }
    
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: nil)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: Int]
            assertEqual(dictionary["foo"], 1)
            assertEqual(dictionary["bar"], 2)
            assertEqual(dictionary["baz"], 3)

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
            let error = box.unbox
            assert(error.domain, ==, NSCocoaErrorDomain)
            assertEqual(error.code, 3840)
        }
    }

    func testURLAcceptHeader() {
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)
        assertEqual(parser.acceptHeader, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: String]
            assertEqual(dictionary["foo"], "1")
            assertEqual(dictionary["bar"], "2")
            assertEqual(dictionary["baz"], "3")

        case .Failure:
            XCTFail()
        }
    }
    
    func testCustomAcceptHeader() {
        let parser = ResponseBodyParser.Custom(acceptHeader: "foo", parseData: { d in success(d) })
        assertEqual(parser.acceptHeader, "foo")
    }

    func testCustomSuccess() {
        let expectedDictionary = ["foo": 1]
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "", parseData: { data in
            return success(expectedDictionary)
        })

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: Int]
            assertEqual(dictionary, expectedDictionary)

        case .Failure:
            XCTFail()
        }
    }

    func testCustomFailure() {
        let expectedError = NSError()
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "", parseData: { data in
            return Result.Failure(Box(expectedError))
        })

        switch parser.parseData(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            assertEqual(box.unbox, expectedError)
        }
    }
}
