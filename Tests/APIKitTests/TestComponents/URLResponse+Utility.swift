import Foundation

extension URLResponse {
    static func dummy(
        url: URL = URL(string: "https://example.com")!,
        statusCode: Int = 200) -> URLResponse {
        
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
    }
}
