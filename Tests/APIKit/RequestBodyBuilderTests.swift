import Foundation
import APIKit
import Result
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: [])

        do {
            let requestBody = try builder.buildRequestBodyFromObject(object)
            XCTAssertEqual(requestBody.contentType, "application/json")

            guard case .Data(let data) = requestBody.entity else {
                XCTFail()
                return
            }

            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            XCTAssertEqual(dictionary["foo"], 1)
            XCTAssertEqual(dictionary["bar"], 2)
            XCTAssertEqual(dictionary["baz"], 3)
        } catch {
            XCTFail()
        }
    }
    
    func testJSONFailure() {
        let object = NSObject()
        let builder = RequestBodyBuilder.JSON(writingOptions: [])

        do {
            try builder.buildRequestBodyFromObject(object)
            XCTFail()
        } catch {
            let nserror = error as NSError
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nserror.code, 3840)
        }
    }

    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.FormURLEncoded(encoding: NSUTF8StringEncoding)

        do {
            let requestBody = try builder.buildRequestBodyFromObject(object)
            XCTAssertEqual(requestBody.contentType, "application/x-www-form-urlencoded")

            guard case .Data(let data) = requestBody.entity else {
                XCTFail()
                return
            }

            let dictionary = try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(dictionary["foo"], "1")
            XCTAssertEqual(dictionary["bar"], "2")
            XCTAssertEqual(dictionary["baz"], "3")
        } catch {
            XCTFail()
        }
    }
    
    func testCustomDataSuccess() {
        let string = "test"

        let expectedContentType = "custom"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom { object in
            return RequestBody(entity: .Data(expectedData), contentType: expectedContentType)
        }

        do {
            let requestBody = try builder.buildRequestBodyFromObject(string)
            XCTAssertEqual(requestBody.contentType, expectedContentType)

            guard case .Data(let data) = requestBody.entity else {
                XCTFail()
                return
            }

            XCTAssertEqual(data, expectedData)
        } catch {
            XCTFail()
        }
    }

    func testMultipartFormDataSuccess() {
        let value1 = "1".dataUsingEncoding(NSUTF8StringEncoding)!
        let value2 = "2".dataUsingEncoding(NSUTF8StringEncoding)!
        let object: [String : AnyObject] = ["foo": value1, "bar": value2]
        let builder = RequestBodyBuilder.MultipartFormData

        do {
            let body = try builder.buildRequestBodyFromObject(object)

            switch body.entity {
            case .InputStream:
                XCTFail()

            case .Data(let data):
                let encodedData = String(data: data, encoding:NSUTF8StringEncoding)!
                let returnCode = "\r\n"

                // Boundary changed each time
                let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
                let regexp = try NSRegularExpression(pattern: pattern, options: [])
                let match = regexp.matchesInString(body.contentType, options: [], range: NSMakeRange(0, (body.contentType as NSString).length))
                XCTAssertTrue(match.count > 0)

                let boundary = (body.contentType as NSString).substringWithRange(match.first!.rangeAtIndex(1))
                XCTAssertEqual(body.contentType, "multipart/form-data; boundary=\(boundary)")
                XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
            }
        } catch {
            XCTFail()
        }
    }

    func testCustomInputStreamSuccess() {
        let string = "test"

        let expectedContentType = "custom"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let expectedInputStream = NSInputStream(data: expectedData)
        let builder = RequestBodyBuilder.Custom { object in
            return RequestBody(entity: .InputStream(expectedInputStream), contentType: expectedContentType)
        }

        do {
            let requestBody = try builder.buildRequestBodyFromObject(string)
            XCTAssertEqual(requestBody.contentType, expectedContentType)

            guard case .InputStream(let inputStream) = requestBody.entity else {
                XCTFail()
                return
            }

            XCTAssertEqual(inputStream, expectedInputStream)
        } catch {
            XCTFail()
        }
    }

    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom { object in
            return RequestBody(entity: .Data(expectedData), contentType: "foo")
        }

        do {
            let body = try builder.buildRequestBodyFromObject(string)

            switch body.entity {
            case .Data(let data):
                XCTAssertEqual(body.contentType, "foo")
                XCTAssertEqual(data, expectedData)

            case .InputStream:
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }

    func testCustomFailure() {
        let string = "test"
        let expectedError = NSError(domain: "Test", code: 1234, userInfo: nil)
        let builder = RequestBodyBuilder.Custom { object in
            throw expectedError
        }

        do {
            try builder.buildRequestBodyFromObject(string)
            XCTFail()
        } catch {
            XCTAssertEqual((error as NSError), expectedError)
        }
    }
}
