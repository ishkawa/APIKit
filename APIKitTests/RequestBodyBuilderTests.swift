import Foundation
import APIKit
import Result
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONHeader() {
        let builder = RequestBodyBuilder.JSON(writingOptions: [])
        XCTAssert(builder.contentTypeHeader == "application/json")
    }
    
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: [])

        do {
            let data = try builder.buildBodyFromObject(object)
            let dictionary = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            XCTAssert(dictionary["foo"] == 1)
            XCTAssert(dictionary["bar"] == 2)
            XCTAssert(dictionary["baz"] == 3)
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
            XCTAssert(nserror.domain == NSCocoaErrorDomain)
            XCTAssert(nserror.code == 3840)
        }
    }
    
    func testURLHeader() {
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)
        XCTAssert(builder.contentTypeHeader == "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)

        do {
            let data = try builder.buildBodyFromObject(object)
            let dictionary = try URLEncodedSerialization.objectFromData(data, encoding: NSUTF8StringEncoding)
            XCTAssert(dictionary["foo"] == "1")
            XCTAssert(dictionary["bar"] == "2")
            XCTAssert(dictionary["baz"] == "3")
        } catch {
            XCTFail()
        }
    }
    
    func testCustomHeader() {
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "foo") { object in
            NSData()
        }
        XCTAssert(builder.contentTypeHeader == "foo")
    }
    
    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "") { object in
            expectedData
        }

        do {
            let data = try builder.buildBodyFromObject(string)
            XCTAssert(data == expectedData)
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
            XCTAssert((error as NSError) == expectedError)
        }
    }
}
