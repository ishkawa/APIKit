import Foundation
import APIKit
import Result
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONHeader() {
        let builder = RequestBodyBuilder.JSON(writingOptions: [])
        XCTAssertEqual(builder.contentTypeHeader, "application/json")
    }
    
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: [])

        do {
            let data = try builder.buildBodyFromObject(object)
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
            try builder.buildBodyFromObject(object)
            XCTFail()
        } catch {
            let nserror = error as NSError
            XCTAssertEqual(nserror.domain, NSCocoaErrorDomain)
            XCTAssertEqual(nserror.code, 3840)
        }
    }
    
    func testURLHeader() {
        let builder = RequestBodyBuilder.FormURLEncoded(encoding: NSUTF8StringEncoding)
        XCTAssertEqual(builder.contentTypeHeader, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.FormURLEncoded(encoding: NSUTF8StringEncoding)

        do {
            let data = try builder.buildBodyFromObject(object)
            let dictionary = try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTAssertEqual(dictionary["foo"], "1")
            XCTAssertEqual(dictionary["bar"], "2")
            XCTAssertEqual(dictionary["baz"], "3")
        } catch {
            XCTFail()
        }
    }
    
    func testCustomHeader() {
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "foo") { object in
            NSData()
        }
        XCTAssertEqual(builder.contentTypeHeader, "foo")
    }
    
    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "") { object in
            expectedData
        }

        do {
            let data = try builder.buildBodyFromObject(string)
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
