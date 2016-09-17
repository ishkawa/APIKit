import XCTest
import APIKit
import XCTest

class FormURLEncodedDataParserTests: XCTestCase {
    func testURLAcceptHeader() {
        let parser = FormURLEncodedDataParser(encoding: .utf8)
        XCTAssertEqual(parser.contentType, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        let parser = FormURLEncodedDataParser(encoding: .utf8)

        do {
            let object = try parser.parse(data: data)
            let dictionary = object as? [String: String]
            XCTAssertEqual(dictionary?["foo"], "1")
            XCTAssertEqual(dictionary?["bar"], "2")
            XCTAssertEqual(dictionary?["baz"], "3")
        } catch {
            XCTFail()
        }
    }

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: &bytes, count: bytes.count)
        let parser = FormURLEncodedDataParser(encoding: .utf8)

        do {
            try _ = parser.parse(data: data)
            XCTFail()
        } catch {
            guard let error = error as? FormURLEncodedDataParser.Error,
                  case .cannotGetStringFromData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
