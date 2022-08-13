import Foundation
import XCTest
@testable import APIKit

class MultipartFormDataParametersTests: XCTestCase {
    // MARK: Entity
    func testDataEntitySuccess() throws {
        let value1 = try XCTUnwrap("1".data(using: .utf8))
        let value2 = try XCTUnwrap("2".data(using: .utf8))

        let parameters = MultipartFormDataBodyParameters(parts: [
            MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
            MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
        ])

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let encodedData = try XCTUnwrap(String(data: data, encoding:.utf8))
        let returnCode = "\r\n"

        let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
        let regexp = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: parameters.contentType.count)
        let match = regexp.matches(in: parameters.contentType, options: [], range: range)
        XCTAssertTrue(match.count > 0)

        let firstRange = try XCTUnwrap(match.first?.range(at: 1))
        let boundary = (parameters.contentType as NSString).substring(with: firstRange)
        XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
        XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
    }

    func testInputStreamEntitySuccess() throws {
        let value1 = try XCTUnwrap("1".data(using: .utf8))
        let value2 = try XCTUnwrap("2".data(using: .utf8))

        let parameters = MultipartFormDataBodyParameters(parts: [
            MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
            MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
        ], entityType: .inputStream)

        guard case .inputStream(let inputStream) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let data = try Data(inputStream: inputStream)
        let encodedData = try XCTUnwrap(String(data: data, encoding:.utf8))
        let returnCode = "\r\n"

        let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
        let regexp = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: parameters.contentType.count)
        let match = regexp.matches(in: parameters.contentType, options: [], range: range)
        XCTAssertTrue(match.count > 0)

        let firstRange = try XCTUnwrap(match.first?.range(at: 1))
        let boundary = (parameters.contentType as NSString).substring(with: firstRange)
        XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
        XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
    }

    // MARK: Values

    func testFileValue() throws {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: type(of: self))
        #endif
        let fileURL = try XCTUnwrap(bundle.url(forResource: "test", withExtension: "json"))
        let part = try MultipartFormDataBodyParameters.Part(fileURL: fileURL, name: "test")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let testData = try Data(contentsOf: fileURL)
        let testString = try XCTUnwrap(String(data: testData, encoding: .utf8))

        let encodedData = try XCTUnwrap(String(data: data, encoding:.utf8))
        let returnCode = "\r\n"

        let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
        let regexp = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: parameters.contentType.count)
        let match = regexp.matches(in: parameters.contentType, options: [], range: range)
        XCTAssertTrue(match.count > 0)

        let firstRange = try XCTUnwrap(match.first?.range(at: 1))
        let boundary = (parameters.contentType as NSString).substring(with: firstRange)
        XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
        XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"test\"; filename=\"test.json\"\r\nContent-Type: application/json\(returnCode)\(returnCode)\(testString)\(returnCode)--\(boundary)--\(returnCode)")
    }

    func testStringValue() throws {
        let part = try MultipartFormDataBodyParameters.Part(value: "abcdef", name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let string = String(data: data, encoding:.utf8)
        XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\nabcdef\r\n--\(parameters.boundary)--\r\n")
    }

    func testIntValue() throws {
        let part = try MultipartFormDataBodyParameters.Part(value: 123, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let string = String(data: data, encoding:.utf8)
        XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n123\r\n--\(parameters.boundary)--\r\n")
    }

    func testDoubleValue() throws {
        let part = try MultipartFormDataBodyParameters.Part(value: 3.14, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        guard case .data(let data) = try parameters.buildEntity() else {
            XCTFail()
            return
        }
        let string = String(data: data, encoding:.utf8)
        XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n3.14\r\n--\(parameters.boundary)--\r\n")
    }
}
