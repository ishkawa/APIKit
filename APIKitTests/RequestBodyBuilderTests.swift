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
