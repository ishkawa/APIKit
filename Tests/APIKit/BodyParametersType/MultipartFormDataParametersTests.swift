import Foundation
import XCTest
@testable import APIKit

class MultipartFormDataParametersTests: XCTestCase {
    func testMultipartFormDataSuccess() {
        for capacity in [1, 255, Int(UInt16.max)] {
            let value1 = "1".dataUsingEncoding(NSUTF8StringEncoding)!
            let value2 = "2".dataUsingEncoding(NSUTF8StringEncoding)!

            let parameters = MultipartFormDataBodyParameters(parts: [
                MultipartFormDataBodyParameters.Part(data: value1, name: "foo"),
                MultipartFormDataBodyParameters.Part(data: value2, name: "bar"),
            ])

            do {
                guard case .InputStream(let inputStream) = try parameters.buildEntity() else {
                    XCTFail()
                    return
                }

                let data = try! NSData(inputStream: inputStream, capacity: capacity)
                let encodedData = String(data: data, encoding:NSUTF8StringEncoding)!
                let returnCode = "\r\n"

                let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
                let regexp = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(location: 0, length: parameters.contentType.characters.count)
                let match = regexp.matchesInString(parameters.contentType, options: [], range: range)
                XCTAssertTrue(match.count > 0)

                let boundary = (parameters.contentType as NSString).substringWithRange(match.first!.rangeAtIndex(1))
                XCTAssertEqual(parameters.contentType, "multipart/form-data; boundary=\(boundary)")
                XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
            } catch {
                XCTFail()
            }
        }
    }

    func testStringValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: "abcdef", name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .InputStream(let inputStream) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let data = try! NSData(inputStream: inputStream, capacity: 64)
            let string = String(data: data, encoding:NSUTF8StringEncoding)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\nabcdef\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }

    func testIntValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: 123, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .InputStream(let inputStream) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let data = try! NSData(inputStream: inputStream, capacity: 64)
            let string = String(data: data, encoding:NSUTF8StringEncoding)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n123\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }

    func testDoubleValue() {
        let part = try! MultipartFormDataBodyParameters.Part(value: 3.14, name: "foo")
        let parameters = MultipartFormDataBodyParameters(parts: [part])

        do {
            guard case .InputStream(let inputStream) = try parameters.buildEntity() else {
                XCTFail()
                return
            }

            let data = try! NSData(inputStream: inputStream, capacity: 64)
            let string = String(data: data, encoding:NSUTF8StringEncoding)!
            XCTAssertEqual(string, "--\(parameters.boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\n\r\n3.14\r\n--\(parameters.boundary)--\r\n")
        } catch {
            XCTFail()
        }
    }
}
