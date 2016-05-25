import XCTest
import Foundation
import APIKit

class StringDataParserTests: XCTestCase {
    func testAcceptHeader() {
        let parser = StringDataParser(encoding: NSUTF8StringEncoding)
        XCTAssertNil(parser.contentType)
    }
    
    func testParseData() {
        let string = "abcdef"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = StringDataParser(encoding: NSUTF8StringEncoding)

        do {
            let object = try parser.parseData(data)
            XCTAssertEqual(object as? String, string)
        } catch {
            XCTFail()
        }
    }

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = NSData(bytes: &bytes, length: bytes.count)
        let parser = StringDataParser(encoding: NSUTF8StringEncoding)

        do {
            try parser.parseData(data)
            XCTFail()
        } catch {
            guard let error = error as? StringDataParser.Error,
                  case .InvalidData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
