import Foundation
import APIKit
import Result
import XCTest

class ResponseBodyParserTests: XCTestCase {
    func testJSONAcceptHeader() {
        let parser = ResponseBodyParser.JSON(readingOptions: [])
        XCTAssert(parser.acceptHeader == "application/json")
    }
    
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: [])

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: Int]
            XCTAssert(dictionary?["foo"] == 1)
            XCTAssert(dictionary?["bar"] == 2)
            XCTAssert(dictionary?["baz"] == 3)
        } catch {
            XCTFail()
        }
    }

    func testJSONFailure() {
        let string = "{\"foo\": 1, \"bar\": 2, \" 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: [])

        do {
            try parser.parseData(data)
            XCTFail()
        } catch {
            let nserror = error as NSError
            XCTAssert(nserror.domain == NSCocoaErrorDomain)
            XCTAssert(nserror.code == 3840)
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

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: String]
            XCTAssert(dictionary?["foo"] == "1")
            XCTAssert(dictionary?["bar"] == "2")
            XCTAssert(dictionary?["baz"] == "3")
        } catch {
            XCTFail()
        }
    }
    
    func testCustomAcceptHeader() {
        let parser = ResponseBodyParser.Custom(acceptHeader: "foo") { data in
            data
        }
        XCTAssert(parser.acceptHeader == "foo")
    }

    func testCustomSuccess() {
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "") { data in
            ["foo": 1]
        }

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: Int]
            XCTAssert(dictionary?["foo"] == 1)
        } catch {
            XCTFail()
        }
    }

    func testCustomFailure() {
        let expectedError = NSError(domain: "Foo", code: 1234, userInfo: nil)
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "") { data in
            throw expectedError
        }

        do {
            try parser.parseData(data)
            XCTFail()
        } catch {
            XCTAssert((error as NSError) == expectedError)
        }
    }
}
