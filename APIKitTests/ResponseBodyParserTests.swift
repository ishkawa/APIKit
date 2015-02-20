import Foundation
import APIKit
import LlamaKit
import XCTest

class ResponseBodyParserTests: XCTestCase {
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(nil)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: Int]
            XCTAssertEqual(dictionary["foo"]!, 1)
            XCTAssertEqual(dictionary["bar"]!, 2)
            XCTAssertEqual(dictionary["baz"]!, 3)

        case .Failure:
            XCTFail()
        }
    }

    func testJSONFailure() {
        let string = "{\"foo\": 1, \"bar\": 2, \" 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(nil)

        switch parser.parseData(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            let error = box.unbox
            XCTAssertEqual(error.domain, NSCocoaErrorDomain)
            XCTAssertEqual(error.code, 3840)
        }
    }

    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.URL(NSUTF8StringEncoding)

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: String]
            XCTAssertEqual(dictionary["foo"]!, "1")
            XCTAssertEqual(dictionary["bar"]!, "2")
            XCTAssertEqual(dictionary["baz"]!, "3")

        case .Failure:
            XCTFail()
        }
    }

    func testCustomSuccess() {
        let expectedDictionary = ["foo": 1]
        let data = NSData()
        let parser = ResponseBodyParser.Custom({ data in
            return Result.Success(Box(expectedDictionary))
        })

        switch parser.parseData(data) {
        case .Success(let box):
            let dictionary = box.unbox as [String: Int]
            XCTAssertEqual(dictionary, expectedDictionary)

        case .Failure:
            XCTFail()
        }
    }

    func testCustomFailure() {
        let expectedError = NSError()
        let data = NSData()
        let parser = ResponseBodyParser.Custom({ data in
            return Result.Failure(Box(expectedError))
        })

        switch parser.parseData(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            XCTAssertEqual(box.unbox, expectedError)
        }
    }
}
