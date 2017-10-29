import Foundation
import XCTest
@testable import APIKit

class MultipartFormDataParametersTests: XCTestCase {
    // MARK: Entity
    func testDataEntitySuccess() {
        let value1 = "1".data(using: .utf8)!
        let value2 = "2".data(using: .utf8)!

        let parameters = MultipartFormDataBodyParameters(parts: [
            MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
            MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
        ])

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let encodedData = String(data: data, encoding:.utf8)!
            let returnCode = "\r\n"

            let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
            let regexp = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: parameters.contentType.count)
            let match = regexp.matches(in: parameters.contentType, options: [], range: range)
            XCTAssertTrue(match.count > 0)

            let boundary = (parameters.contentType as NSString).substring(with: match.first!.range(at: 1))
            XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
            XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
        } catch {
            XCTFail()
        }
    }

    func testInputStreamEntitySuccess() {
        let value1 = "1".data(using: .utf8)!
        let value2 = "2".data(using: .utf8)!

        let parameters = MultipartFormDataBodyParameters(parts: [
            MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
            MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
        ], entityType: .inputStream)

        do {
            guard case .inputStream(let inputStream) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let data = try Data(inputStream: inputStream)
            let encodedData = String(data: data, encoding:.utf8)!
            let returnCode = "\r\n"

            let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
            let regexp = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: parameters.contentType.count)
            let match = regexp.matches(in: parameters.contentType, options: [], range: range)
            XCTAssertTrue(match.count > 0)

            let boundary = (parameters.contentType as NSString).substring(with: match.first!.range(at: 1))
            XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
            XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
        } catch {
            XCTFail()
        }
    }

    // MARK: Values

    // Skip test cases that uses files until SwiftPM supports resources.
    #if !SWIFT_PACKAGE
    func testFileValue() {
        let fileURL = Bundle(for: type(of: self)).url(forResource: "test", withExtension: "json")!
        let part = try! MultipartFormDataBodyParameters.Part(fileURL: fileURL, name: "test")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let testData = try! Data(contentsOf: fileURL)
            let testString = String(data: testData, encoding: .utf8)!

            let encodedData = String(data: data, encoding:.utf8)!
            let returnCode = "\r\n"

            let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
            let regexp = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: parameters.contentType.count)
            let match = regexp.matches(in: parameters.contentType, options: [], range: range)
            XCTAssertTrue(match.count > 0)

            let boundary = (parameters.contentType as NSString).substring(with: match.first!.range(at: 1))
            XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
            XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"test\"; filename=\"test.json\"\r\nContent-Type: application/json\(returnCode)\(returnCode)\(testString)\(returnCode)--\(boundary)--\(returnCode)")
        } catch {
            XCTFail()
        }
    }
    #endif

    func testStringValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: "abcdef", name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let string = String(data: data, encoding:.utf8)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\nabcdef\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }

    func testIntValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: 123, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let string = String(data: data, encoding:.utf8)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n123\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }

    func testDoubleValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: 3.14, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .data(let data) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let string = String(data: data, encoding:.utf8)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n3.14\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }
}
