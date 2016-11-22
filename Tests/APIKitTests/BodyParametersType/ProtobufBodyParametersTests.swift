import Foundation
import XCTest
import APIKit

class ProtobufBodyParametersTests: XCTestCase {
    func testProtobufSuccess() {
        let object = NSKeyedArchiver.archivedData(withRootObject: ["foo": 1, "bar": 2, "baz": 3])
        let parameters = ProtobufBodyParameters(protobufObject: object)
        XCTAssertEqual(parameters.contentType, "application/protobuf")

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let dictionary = NSKeyedUnarchiver.unarchiveObject(with: data) as? [String: Int]
            XCTAssertEqual(dictionary?["foo"], 1)
            XCTAssertEqual(dictionary?["bar"], 2)
            XCTAssertEqual(dictionary?["baz"], 3)
        } catch {
            XCTFail()
        }
    }
}
