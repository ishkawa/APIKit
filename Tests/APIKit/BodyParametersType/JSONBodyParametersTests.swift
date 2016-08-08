import Foundation
import XCTest
import APIKit

class JSONBodyParametersTests: XCTestCase {
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let parameters = JSONBodyParameters(JSONObject: object)
        XCTAssertEqual(parameters.contentType, "application/json")

        do {
            guard case .Data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertEqual(dictionary["foo"], 1)
            XCTAssertEqual(dictionary["bar"], 2)
            XCTAssertEqual(dictionary["baz"], 3)
        } catch {
            XCTFail()
        }
    }

    func testJSONFailure() {
        let object = NSObject()
        let parameters = JSONBodyParameters(JSONObject: object)

        do {
            try _ = parameters.buildEntity()
            XCTFail()
        } catch {
            let nserror = error as NSError
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nserror.code, 3840)
        }
    }
}
