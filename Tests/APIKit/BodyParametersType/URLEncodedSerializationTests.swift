import Foundation
import XCTest
import APIKit

class URLEncodedSerializationTests: XCTestCase {
    // MARK: NSData -> AnyObject
    func testObjectFromData() {
        let data = "key1=value1&key2=value2".dataUsingEncoding(NSUTF8StringEncoding)!
        let object = try? URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
        XCTAssertEqual(object?["key1"], "value1")
        XCTAssertEqual(object?["key2"], "value2")
    }

    func testInvalidFormatString() {
        let string = "key==value&"

        do {
            let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
            try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
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
        let data = NSData(bytes: &bytes, length: bytes.count)

        do {
            try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTFail()
        } catch {
            guard let error = error as? URLEncodedSerialization.Error,
                  case .CannotGetStringFromData(let invalidData, let encoding) = error else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, invalidData)
            XCTAssertEqual(encoding, NSUTF8StringEncoding)
        }
    }

    // MARK: AnyObject -> NSData
    func testDataFromObject() {
        let object = ["hey": "yo"] as AnyObject
        let data = try? URLEncodedSerialization.dataFromObject(object, encoding: NSUTF8StringEncoding)
        let string = data.flatMap { NSString(data: $0, encoding: NSUTF8StringEncoding) }
        XCTAssertEqual(string, "hey=yo")
    }

    func testNonDictionaryObject() {
        let dictionaries = [["hey": "yo"]] as AnyObject

        do {
            try URLEncodedSerialization.dataFromObject(dictionaries, encoding: NSUTF8StringEncoding)
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
