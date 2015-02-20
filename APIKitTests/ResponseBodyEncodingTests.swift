import UIKit
import APIKit
import LlamaKit
import XCTest

class ResponseBodyEncodingTests: XCTestCase {
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let encoding = ResponseBodyEncoding.JSON(nil)

        switch encoding.decode(data) {
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
        let encoding = ResponseBodyEncoding.JSON(nil)

        switch encoding.decode(data) {
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
        let encoding = ResponseBodyEncoding.URL(NSUTF8StringEncoding)

        switch encoding.decode(data) {
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
        let encoding = ResponseBodyEncoding.Custom({ data in
            return Result.Success(Box(expectedDictionary))
        })

        switch encoding.decode(data) {
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
        let encoding = ResponseBodyEncoding.Custom({ data in
            return Result.Failure(Box(expectedError))
        })

        switch encoding.decode(data) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            XCTAssertEqual(box.unbox, expectedError)
        }
    }
}
