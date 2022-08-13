import XCTest
import APIKit
import XCTest

class ProtobufDataParserTests: XCTestCase {
    func testContentType() {
        let parser = ProtobufDataParser()
        XCTAssertEqual(parser.contentType, "application/protobuf")
    }
    
    func testProtobufSuccess() throws {
        let data = NSKeyedArchiver.archivedData(withRootObject: ["foo": 1, "bar": 2, "baz": 3])
        let parser = ProtobufDataParser()
        
        let object = try XCTUnwrap(try parser.parse(data: data) as? Data)
        let dictionary = NSKeyedUnarchiver.unarchiveObject(with: object) as? [String: Int]
        XCTAssertEqual(dictionary?["foo"], 1)
        XCTAssertEqual(dictionary?["bar"], 2)
        XCTAssertEqual(dictionary?["baz"], 3)
    }
}
