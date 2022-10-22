import Foundation
import XCTest
import APIKit

class ProtobufBodyParametersTests: XCTestCase {
    func testProtobufSuccess() throws {
        let object = try XCTUnwrap("data".data(using: .utf8))
        let parameters = ProtobufBodyParameters(protobufObject: object)
        XCTAssertEqual(parameters.contentType, "application/protobuf")

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let string = String(data: data, encoding: .utf8)
        XCTAssertEqual(string, "data")
    }
}
