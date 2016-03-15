import Foundation
import XCTest
import APIKit

class FormURLEncodedBodyParametersTests: XCTestCase {
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let parameters = FormURLEncodedBodyParameters(formObject: object)
        XCTAssertEqual(parameters.contentType, "application/x-www-form-urlencoded")

        do {
            guard case .Data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let dictionary = try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(dictionary["foo"], "1")
            XCTAssertEqual(dictionary["bar"], "2")
            XCTAssertEqual(dictionary["baz"], "3")
        } catch {
            XCTFail()
        }
    }
}
