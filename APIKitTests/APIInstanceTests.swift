import Foundation
import Assertions
import APIKit
import XCTest

class APIInstanceTests: XCTestCase {
    class Foo: API {
        // NOTE: these are required to avoid segmentation fault of compliler (Swift 1.1)
        override class func requestBodyBuilder() -> RequestBodyBuilder {
            return .JSON(writingOptions: nil)
        }
        
        override class func responseBodyParser() -> ResponseBodyParser {
            return .JSON(readingOptions: nil)
        }
    }
    
    class Bar: API {
    }

    func testDifferentSessionsAreCreatedForEachClasses() {
        assert(Foo.URLSession, !=, Bar.URLSession)
    }
    
    func testSameSessionsAreUsedInSameClasses() {
        assertEqual(Foo.URLSession, Foo.URLSession)
        assertEqual(Bar.URLSession, Bar.URLSession)
    }
    
    func testDelegateOfSessions() {
        assert(Foo.URLSession.delegate, { $0 is Foo })
        assert(Bar.URLSession.delegate, { $0 is Bar })
    }
}
