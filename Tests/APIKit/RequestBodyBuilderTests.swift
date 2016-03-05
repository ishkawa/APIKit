import Foundation
import APIKit
import Result
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: [])

        do {
            let (contentTypeHeader, data) = try builder.buildBodyFromObject(object)
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            XCTAssertEqual(contentTypeHeader, "application/json")
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
            try builder.buildBodyFromObject(object)
            XCTFail()
        } catch {
            let nserror = error as NSError
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nserror.code, 3840)
        }
    }

    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)

        do {
            let (contentTypeHeader, data) = try builder.buildBodyFromObject(object)
            let dictionary = try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(contentTypeHeader, "application/x-www-form-urlencoded")
            XCTAssertEqual(dictionary["foo"], "1")
            XCTAssertEqual(dictionary["bar"], "2")
            XCTAssertEqual(dictionary["baz"], "3")
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
            let (contentTypeHeader, data) = try builder.buildBodyFromObject(object)
            let encodedData = String(data: data, encoding:NSUTF8StringEncoding)!
            let returnCode = "\r\n"
            // Boundary changed each time
            let pattern = "^multipart/form-data; boundary=([\\w.]+)$"
            let regexp = try NSRegularExpression(pattern: pattern, options: [])
            let match = regexp.matchesInString(contentTypeHeader, options: [], range: NSMakeRange(0, (contentTypeHeader as NSString).length))
            XCTAssertTrue(match.count > 0)
            let boundary = (contentTypeHeader as NSString).substringWithRange(match.first!.rangeAtIndex(1))

            XCTAssertEqual(contentTypeHeader, "multipart/form-data; boundary=\(boundary)")
            XCTAssertEqual(encodedData, "--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"foo\"\(returnCode)\(returnCode)1\(returnCode)--\(boundary)\(returnCode)Content-Disposition: form-data; name=\"bar\"\(returnCode)\(returnCode)2\(returnCode)--\(boundary)--\(returnCode)")
        } catch {
            XCTFail()
        }
    }

    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "foo") { object in
            expectedData
        }

        do {
            let (contentTypeHeader, data) = try builder.buildBodyFromObject(string)
            XCTAssertEqual(contentTypeHeader, "foo")
            XCTAssertEqual(data, expectedData)
        } catch {
            XCTFail()
        }
    }

    func testCustomFailure() {
        let string = "foo"
        let expectedError = NSError(domain: "Foo", code: 1234, userInfo: nil)
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "") { object in
            throw expectedError
        }

        do {
            try builder.buildBodyFromObject(string)
            XCTFail()
        } catch {
            XCTAssertEqual((error as NSError), expectedError)
        }
    }
}
