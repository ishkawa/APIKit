import XCTest
import APIKit
import XCTest

class ProtobufDataParserTests: XCTestCase {
    func testContentType() {
        let parser = ProtobufDataParser()
        XCTAssertEqual(parser.contentType, "application/protobuf")
    }
    
    func testJSONSuccess() {
        let dictionary = [
            "foo": 1,
            "bar": 2,
            "baz": 3
        ]
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        let parser = ProtobufDataParser()
        
        do {
            let object = try parser.parse(data: data) as! Data
            let parsedDictionary = NSKeyedUnarchiver.unarchiveObject(with: object) as! [String: Int]
            XCTAssertEqual(parsedDictionary["foo"], dictionary["foo"])
            XCTAssertEqual(parsedDictionary["bar"], dictionary["bar"])
            XCTAssertEqual(parsedDictionary["baz"], dictionary["baz"])
        } catch {
            XCTFail()
        }
    }
}
