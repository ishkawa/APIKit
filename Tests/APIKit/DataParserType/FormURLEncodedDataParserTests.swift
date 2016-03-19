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
}
