import Foundation
import XCTest
import APIKit

class URLEncodedSerializationTests: XCTestCase {
    // MARK: NSData -> Any
    func testObjectFromData() {
        let data = "key1=value1&key2=value2".data(using: .utf8)!
        let object = try? URLEncodedSerialization.object(from: data, encoding: .utf8)
        XCTAssertEqual(object?["key1"], "value1")
        XCTAssertEqual(object?["key2"], "value2")
    }

    func testInvalidFormatString() {
        let string = "key==value&"

        do {
            let data = string.data(using: .utf8)!
            try _ = URLEncodedSerialization.object(from: data, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .invalidFormatString(let invalidString) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(string, invalidString)
        }
    }

    func testInvalidString() {
        var bytes = [UInt8]([0xed, 0xa0, 0x80]) // U+D800 (high surrogate)
        let data = Data(bytes: &bytes, count: bytes.count)

        do {
            try _ = URLEncodedSerialization.object(from: data, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .cannotGetStringFromData(let invalidData, let encoding) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
            XCTAssertEqual(encoding, .utf8)
        }
    }

    // MARK: Any -> NSData
    func testDataFromObject() {
        let object = ["hey": "yo"] as Any
        let data = try? URLEncodedSerialization.data(from: object, encoding: .utf8)
        let string = data.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(string, "hey=yo")
    }

    func testNonDictionaryObject() {
        let dictionaries = [["hey": "yo"]] as Any

        do {
            try _ = URLEncodedSerialization.data(from: dictionaries, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .cannotCastObjectToDictionary(let object) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual((object as AnyObject)["hey"], (dictionaries as AnyObject)["hey"])
        }
    }
}
