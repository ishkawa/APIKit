import Foundation
import XCTest
import APIKit

class URLEncodedSerializationTests: XCTestCase {
    // MARK: NSData -> AnyObject
    func testObjectFromData() {
        let data = "key1=value1&key2=value2".data(using: .utf8)!
        let object = try? URLEncodedSerialization.objectFromData(data, encoding: .utf8)
        XCTAssertEqual(object?["key1"], "value1")
        XCTAssertEqual(object?["key2"], "value2")
    }

    func testInvalidFormatString() {
        let string = "key==value&"

        do {
            let data = string.data(using: .utf8)!
            try _ = URLEncodedSerialization.objectFromData(data, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .InvalidFormatString(let invalidString) = error else {
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
            try _ = URLEncodedSerialization.objectFromData(data, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .CannotGetStringFromData(let invalidData, let encoding) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
            XCTAssertEqual(encoding, .utf8)
        }
    }

    // MARK: AnyObject -> NSData
    func testDataFromObject() {
        let object = ["hey": "yo"] as AnyObject
        let data = try? URLEncodedSerialization.dataFromObject(object, encoding: .utf8)
        let string = data.flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(string, "hey=yo")
    }

    func testNonDictionaryObject() {
        let dictionaries = [["hey": "yo"]] as AnyObject

        do {
            try _ = URLEncodedSerialization.dataFromObject(dictionaries, encoding: .utf8)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .CannotCastObjectToDictionary(let object) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(object["hey"], dictionaries["hey"])
        }
    }
}
