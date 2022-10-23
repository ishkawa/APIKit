import XCTest
import APIKit
import XCTest

class ProtobufDataParserTests: XCTestCase {
    func testContentType() {
        let parser = ProtobufDataParser()
        XCTAssertEqual(parser.contentType, "application/protobuf")
    }
    
    func testProtobufSuccess() throws {
        let data = try XCTUnwrap("data".data(using: .utf8))
        let parser = ProtobufDataParser()
        
        let object = try parser.parse(data: data)
        let string = String(data: object, encoding: .utf8)
        XCTAssertEqual(string, "data")
    }
}
