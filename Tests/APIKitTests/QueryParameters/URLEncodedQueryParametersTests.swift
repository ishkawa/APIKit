import XCTest
import APIKit

class URLEncodedQueryParametersTests: XCTestCase {
    func testURLEncodedSuccess() {
        let object: [String: Any] = ["foo": "string", "bar": 1, "q": "こんにちは"]
        let parameters = URLEncodedQueryParameters(parameters: object)
        guard let query = parameters.encode() else {
            XCTFail()
            return
        }

        let items = query.components(separatedBy: "&")
        XCTAssertEqual(items.count, 3)
        XCTAssertTrue(items.contains("foo=string"))
        XCTAssertTrue(items.contains("bar=1"))
        XCTAssertTrue(items.contains("q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF"))
    }
}
