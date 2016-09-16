import Foundation

/// `DataParser` protocol provides inteface to parse HTTP response body and to state Content-Type to accept.
public protocol DataParser {
    /// Value for `Accept` header field of HTTP request.
    var contentType: String? { get }

    /// Return `Any` that expresses structure of response such as JSON and XML.
    /// - Throws: `ErrorType` when parser encountered invalid format data.
    func parse(data: Data) throws -> Any
}
