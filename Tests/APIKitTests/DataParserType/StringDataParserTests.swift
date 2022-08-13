import XCTest
import Foundation
import APIKit

class StringDataParserTests: XCTestCase {
    func testAcceptHeader() {
        let parser = StringDataParser(encoding: .utf8)
        XCTAssertNil(parser.contentType)
    }
    
    func testParseData() throws {
        let string = "abcdef"
        let data = string.data(using: .utf8, allowLossyConversion: false)!
        let parser = StringDataParser(encoding: .utf8)

        let object = try parser.parse(data: data)
        XCTAssertEqual(object as? String, string)
    }

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: &bytes, count: bytes.count)
        let parser = StringDataParser(encoding: .utf8)

        XCTAssertThrowsError(try parser.parse(data: data)) { error in
            guard let error = error as? StringDataParser.Error,
                  case .invalidData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
