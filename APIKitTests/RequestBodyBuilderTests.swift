import Foundation
import APIKit
import Assertions
import LlamaKit
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONHeader() {
        let builder = RequestBodyBuilder.JSON(writingOptions: nil)
        assertEqual(builder.contentTypeHeader, "application/json")
    }
    
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: nil)

        switch builder.buildBodyFromObject(object) {
        case .Success(let box):
            let dictionary = NSJSONSerialization.JSONObjectWithData(box.unbox, options: nil, error: nil) as [String: Int]
            assertEqual(dictionary["foo"], 1)
            assertEqual(dictionary["bar"], 2)
            assertEqual(dictionary["baz"], 3)

        case .Failure:
            XCTFail()
        }
    }
    
    func testJSONFailure() {
        let object = NSObject()
        let builder = RequestBodyBuilder.JSON(writingOptions: nil)

        switch builder.buildBodyFromObject(object) {
        case .Success:
            XCTFail()
            
        case .Failure(let box):
            let error =  box.unbox
            assertEqual(error.domain, APIKitRequestBodyBuidlerErrorDomain)
            assertEqual(error.code, 0)
        }
    }
    
    func testURLHeader() {
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)
        assertEqual(builder.contentTypeHeader, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)

        switch builder.buildBodyFromObject(object) {
        case .Success(let box):
            let dictionary =  URLEncodedSerialization.objectFromData(box.unbox, encoding: NSUTF8StringEncoding, error: nil) as [String: String]
            assertEqual(dictionary["foo"], "1")
            assertEqual(dictionary["bar"], "2")
            assertEqual(dictionary["baz"], "3")

        case .Failure:
            XCTFail()
        }
    }
    
    func testCustomHeader() {
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "foo", buildBodyFromObject: { o in success(o as NSData) })
        assertEqual(builder.contentTypeHeader, "foo")
    }
    
    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "", buildBodyFromObject: { object in
            return success(expectedData)
        })

        switch builder.buildBodyFromObject(string) {
        case .Success(let box):
            assertEqual(box.unbox, expectedData)

        case .Failure:
            XCTFail()
        }
    }

    func testCustomFailure() {
        let string = "foo"
        let expectedError = NSError()
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "", buildBodyFromObject: { object in
            return failure(expectedError)
        })

        switch builder.buildBodyFromObject(string) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            assertEqual(box.unbox, expectedError)
        }
    }
}
