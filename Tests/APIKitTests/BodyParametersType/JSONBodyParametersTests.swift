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

    func testDictionaryLiteral() {
        let object = ["foo": 1, "bar": 2, "baz": 3]

        let parameters1: JSONBodyParameters = .init(JSONObject: object)
        let parameters2: JSONBodyParameters = ["foo": 1, "bar": 2, "baz": 3]
        do {
            guard case .data(let data1) = try parameters1.buildEntity(),
                case .data(let data2) = try parameters2.buildEntity() else {
                XCTFail()
                return
            }
            let dictionary1 = try JSONSerialization.jsonObject(with: data1, options: [])
            let dictionary2 = try JSONSerialization.jsonObject(with: data2, options: [])
            XCTAssertEqual((dictionary1 as? [String: Int])?["foo"], (dictionary2 as? [String: Int])?["foo"])
            XCTAssertEqual((dictionary1 as? [String: Int])?["bar"], (dictionary2 as? [String: Int])?["bar"])
            XCTAssertEqual((dictionary1 as? [String: Int])?["baz"], (dictionary2 as? [String: Int])?["baz"])
        } catch {
            XCTFail()
        }
    }
}
