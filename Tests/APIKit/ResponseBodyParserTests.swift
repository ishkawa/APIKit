import Foundation
import APIKit
import Result
import XCTest

class ResponseBodyParserTests: XCTestCase {
    func testJSONAcceptHeader() {
        let parser = ResponseBodyParser.JSON(readingOptions: [])
        XCTAssertEqual(parser.acceptHeader, "application/json")
    }
    
    func testJSONSuccess() {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.JSON(readingOptions: [])

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: Int]
            XCTAssertEqual(dictionary?["foo"], 1)
            XCTAssertEqual(dictionary?["bar"], 2)
            XCTAssertEqual(dictionary?["baz"], 3)
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
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nserror.code, 3840)
        }
    }

    func testURLAcceptHeader() {
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)
        XCTAssertEqual(parser.acceptHeader, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = ResponseBodyParser.URL(encoding: NSUTF8StringEncoding)

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: String]
            XCTAssertEqual(dictionary?["foo"], "1")
            XCTAssertEqual(dictionary?["bar"], "2")
            XCTAssertEqual(dictionary?["baz"], "3")
        } catch {
            XCTFail()
        }
    }
    
    func testCustomAcceptHeader() {
        let parser = ResponseBodyParser.Custom(acceptHeader: "foo") { data in
            data
        }
        XCTAssertEqual(parser.acceptHeader, "foo")
    }

    func testCustomSuccess() {
        let data = NSData()
        let parser = ResponseBodyParser.Custom(acceptHeader: "") { data in
            ["foo": 1]
        }

        do {
            let object = try parser.parseData(data)
            let dictionary = object as? [String: Int]
            XCTAssertEqual(dictionary?["foo"], 1)
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
            XCTAssertEqual((error as NSError), expectedError)
        }
    }
}
