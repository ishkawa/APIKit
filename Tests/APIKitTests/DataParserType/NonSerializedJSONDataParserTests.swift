import XCTest
import APIKit
import XCTest

class NonSerializedJSONDataParserTests: XCTestCase {
    func testContentType() {
        let parser = NonSerializedJSONDataParser()
        XCTAssertEqual(parser.contentType, "application/json")
    }

    func testJSONSuccess() throws {
        let data = try XCTUnwrap("data".data(using: .utf8))
        let parser = NonSerializedJSONDataParser()

        let object = try parser.parse(data: data)
        XCTAssertEqual(object, data)
    }
}
