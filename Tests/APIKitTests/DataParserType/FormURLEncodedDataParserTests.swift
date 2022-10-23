import XCTest
import APIKit
import XCTest

class FormURLEncodedDataParserTests: XCTestCase {
    func testURLAcceptHeader() {
        let parser = FormURLEncodedDataParser(encoding: .utf8)
        XCTAssertEqual(parser.contentType, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() throws {
        let string = "foo=1&bar=2&baz=3"
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        let parser = FormURLEncodedDataParser(encoding: .utf8)

        let object = try parser.parse(data: data)
        XCTAssertEqual(object["foo"] as? String, "1")
        XCTAssertEqual(object["bar"] as? String, "2")
        XCTAssertEqual(object["baz"] as? String, "3")
    }

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: &bytes, count: bytes.count)
        let parser = FormURLEncodedDataParser(encoding: .utf8)

        XCTAssertThrowsError(try parser.parse(data: data)) { error in
            guard let error = error as? FormURLEncodedDataParser.Error,
                  case .cannotGetStringFromData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
