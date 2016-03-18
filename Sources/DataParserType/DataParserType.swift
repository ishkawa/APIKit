import Foundation

/// A type that parses HTTP response body and states Content-Type to accept.
public protocol DataParserType {
    /// Value for `Accept` header field of HTTP request.
    var contentType: String? { get }

    /// Return `AnyObject` that expresses structure of response such as JSON and XML. 
    /// - Throws: `ErrorType` when parser encountered invalid format data.
    func parseData(data: NSData) throws -> AnyObject
}
