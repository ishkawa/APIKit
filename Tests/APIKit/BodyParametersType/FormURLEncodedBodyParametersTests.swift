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

            let string = NSString(data: data, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(string, "baz=3&foo=1&bar=2")
        } catch {
            XCTFail()
        }
    }
}
