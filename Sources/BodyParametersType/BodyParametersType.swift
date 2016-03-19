import Foundation

/// `RequestBodyEntity` represents entity of HTTP body.
public enum RequestBodyEntity {
    /// Expresses entity as `NSData`. The associated value will be set to `NSURLRequest.HTTPBody`.
    case Data(NSData)

    /// Expresses entity as `NSInputStream`. The associated value will be set to `NSURLRequest.HTTPBodyStream`.
    case InputStream(NSInputStream)
}

/// `BodyParametersType` provides interface to parse HTTP response body and to state `Content-Type` to accept.
public protocol BodyParametersType {
    /// `Content-Type` to accept. The value for this property will be set to `Accept` HTTP header field.
    var contentType: String { get }

    /// Builds `RequestBodyEntity`.
    /// Throws: `ErrorType`
    func buildEntity() throws -> RequestBodyEntity
}
