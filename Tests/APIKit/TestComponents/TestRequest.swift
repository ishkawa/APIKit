import Foundation
import APIKit

struct TestRequest: RequestType {
    typealias Response = AnyObject

    init(baseURL: NSURL = NSURL(string: "https://example.com")!, path: String = "/", method: HTTPMethod = .GET, parameters: AnyObject? = [:], HTTPHeaderFields: [String: String] = [:]) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.parameters = parameters
        self.HTTPHeaderFields = HTTPHeaderFields
    }

    let baseURL: NSURL
    let method: HTTPMethod
    let path: String
    let parameters: AnyObject?
    let HTTPHeaderFields: [String: String]

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return object
    }
}
