import Foundation
import APIKit
import LlamaKit
import XCTest

class RequestBodyBuilderTests: XCTestCase {
    func testJSONHeader() {
        let builder = RequestBodyBuilder.JSON(writingOptions: nil)
        XCTAssertEqual(builder.contentTypeHeader, "application/json")
    }
    
    func testJSONSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.JSON(writingOptions: nil)

        switch builder.buildBodyFromObject(object) {
        case .Success(let box):
            let dictionary = NSJSONSerialization.JSONObjectWithData(box.unbox, options: nil, error: nil) as [String: Int]
            XCTAssertEqual(dictionary["foo"]!, 1)
            XCTAssertEqual(dictionary["bar"]!, 2)
            XCTAssertEqual(dictionary["baz"]!, 3)

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
            XCTAssertEqual(error.domain, APIKitRequestBodyBuidlerErrorDomain)
            XCTAssertEqual(error.code, 0)
        }
    }
    
    func testURLHeader() {
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)
        XCTAssertEqual(builder.contentTypeHeader, "application/x-www-form-urlencoded")
    }
    
    func testURLSuccess() {
        let object = ["foo": 1, "bar": 2, "baz": 3]
        let builder = RequestBodyBuilder.URL(encoding: NSUTF8StringEncoding)

        switch builder.buildBodyFromObject(object) {
        case .Success(let box):
            let string = NSString(data: box.unbox, encoding: NSUTF8StringEncoding)!
            XCTAssertEqual(string, "baz=3&foo=1&bar=2")

        case .Failure:
            XCTFail()
        }
    }
    
    func testCustomHeader() {
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "foo", buildBodyFromObject: { o in Result.Success(Box(o as NSData)) })
        XCTAssertEqual(builder.contentTypeHeader, "foo")
    }
    
    func testCustomSuccess() {
        let string = "foo"
        let expectedData = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "", buildBodyFromObject: { object in
            return Result.Success(Box(expectedData))
        })

        switch builder.buildBodyFromObject(string) {
        case .Success(let box):
            XCTAssertEqual(box.unbox, expectedData)

        case .Failure:
            XCTFail()
        }
    }

    func testCustomFailure() {
        let string = "foo"
        let expectedError = NSError()
        let builder = RequestBodyBuilder.Custom(contentTypeHeader: "", buildBodyFromObject: { object in
            return Result.Failure(Box(expectedError))
        })

        switch builder.buildBodyFromObject(string) {
        case .Success:
            XCTFail()

        case .Failure(let box):
            XCTAssertEqual(box.unbox, expectedError)
        }
    }
}
