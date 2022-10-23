import XCTest
import APIKit
import XCTest

class JSONDataParserTests: XCTestCase {
    func testContentType() {
        let parser = JSONDataParser(readingOptions: [])
        XCTAssertEqual(parser.contentType, "application/json")
    }
    
    func testDictionaryJSONSuccess() throws {
        let string = "{\"foo\": 1, \"bar\": 2, \"baz\": 3}"
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        let parser = JSONDataParser(readingOptions: [])

        let object = try parser.parse(data: data)
        let dictionary = object as? [String: Int]
        XCTAssertEqual(dictionary?["foo"], 1)
        XCTAssertEqual(dictionary?["bar"], 2)
        XCTAssertEqual(dictionary?["baz"], 3)
    }

    func testArrayJSONSuccess() throws {
        let string = "[1, 2, 3]"
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        let parser = JSONDataParser(readingOptions: [])

        let object = try parser.parse(data: data)
        let array = object as? [Int]
        XCTAssertEqual(array?[0], 1)
        XCTAssertEqual(array?[1], 2)
        XCTAssertEqual(array?[2], 3)
    }
}
