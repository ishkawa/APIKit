import XCTest
import APIKit
import XCTest

class FormURLEncodedDataParserTests: XCTestCase {
    func testURLAcceptHeader() {
        let parser = FormURLEncodedDataParser(encoding: NSUTF8StringEncoding)
        XCTAssertEqual(parser.contentType, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let string = "foo=1&bar=2&baz=3"
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let parser = FormURLEncodedDataParser(encoding: NSUTF8StringEncoding)

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

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = NSData(bytes: &bytes, length: bytes.count)
        let parser = FormURLEncodedDataParser(encoding: NSUTF8StringEncoding)

        do {
            try parser.parseData(data)
            XCTFail()
        } catch {
            guard let error = error as? FormURLEncodedDataParser.Error,
                  case .CannotGetStringFromData(let invalidData) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
        }
    }
}
