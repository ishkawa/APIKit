import Foundation
import APIKit

struct TestRequest: RequestType {
    var absoluteURL: NSURL? {
        let URLRequest = try? buildURLRequest()
        return URLRequest?.URL
    }

    // MARK: RequestType
    typealias Response = AnyObject

    init(baseURL: String = "https://example.com", path: String = "/", method: HTTPMethod = .GET, parameters: AnyObject? = [:], headerFields: [String: String] = [:]) {
        self.baseURL = NSURL(string: baseURL)!
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headerFields = headerFields
    }

    let baseURL: NSURL
    let method: HTTPMethod
    let path: String
    let parameters: AnyObject?
    let headerFields: [String: String]

    func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
        return object
    }
}
