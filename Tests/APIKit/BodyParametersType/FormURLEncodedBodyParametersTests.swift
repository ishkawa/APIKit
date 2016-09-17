import Foundation
import XCTest
import APIKit

class FormURLEncodedBodyParametersTests: XCTestCase {
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let parameters = FormURLEncodedBodyParameters(formObject: object)
        XCTAssertEqual(parameters.contentType, "application/x-www-form-urlencoded")

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let createdObject = try URLEncodedSerialization.object(from: data, encoding: .utf8)
            XCTAssertEqual(createdObject["foo"], "1")
            XCTAssertEqual(createdObject["bar"], "2")
            XCTAssertEqual(createdObject["baz"], "3")
        } catch {
            XCTFail()
        }
    }

    // NSURLComponents crashes on iOS 8.2 or earlier while escaping long CJK string.
    // This test ensures that FormURLEncodedBodyParameters avoids this issue correctly.
    func testLongCJKString() {
        let key = "key"
        let value = "一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"
        let parameters = FormURLEncodedBodyParameters(formObject: [key: value])
        _ = try? parameters.buildEntity()
    }
}
