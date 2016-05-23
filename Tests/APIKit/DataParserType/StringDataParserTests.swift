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
}
