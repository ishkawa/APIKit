import Foundation
import XCTest
import APIKit

class JSONBodyParametersTests: XCTestCase {
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let parameters = JSONBodyParameters(JSONObject: object)
        XCTAssertEqual(parameters.contentType, "application/json")

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
            XCTAssertEqual((dictionary as? [String: Int])?["foo"], 1)
            XCTAssertEqual((dictionary as? [String: Int])?["bar"], 2)
            XCTAssertEqual((dictionary as? [String: Int])?["baz"], 3)
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
