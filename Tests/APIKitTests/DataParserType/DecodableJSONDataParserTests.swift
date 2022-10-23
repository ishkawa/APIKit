import XCTest
import APIKit
import XCTest

class DecodableJSONDataParserTests: XCTestCase {
    func testContentType() {
        let parser = DecodableJSONDataParser()
        XCTAssertEqual(parser.contentType, "application/json")
    }

    func testJSONSuccess() throws {
        let data = try XCTUnwrap("data".data(using: .utf8))
        let parser = DecodableJSONDataParser()

        let object = try parser.parse(data: data)
        XCTAssertEqual(object, data)
    }
}
