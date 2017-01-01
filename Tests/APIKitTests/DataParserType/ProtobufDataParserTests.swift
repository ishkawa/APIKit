import Foundation
import APIKit
import XCTest

class ProtobufDataParserTests: XCTestCase {
    func testContentType() {
        let parser = ProtobufDataParser()
        XCTAssertEqual(parser.contentType, "application/protobuf")
    }
    
    func testProtobufSuccess() {
        let data = "data".data(using: .utf8)!
        let parser = ProtobufDataParser()
        
        do {
            let object = try parser.parse(data: data) as! Data
            let string = String(data: object, encoding: .utf8)
            XCTAssertEqual(string, "data")
        } catch {
            XCTFail()
        }
    }
}
