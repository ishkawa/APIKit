import Foundation

/// `RequestBodyEntity` represents entity of HTTP body.
public enum RequestBodyEntity {
    /// Expresses entity as `Data`. The associated value will be set to `URLRequest.HTTPBody`.
    case Data(Data)

    /// Expresses entity as `InputStream`. The associated value will be set to `URLRequest.HTTPBodyStream`.
    case InputStream(InputStream)
}

/// `BodyParametersType` provides interface to parse HTTP response body and to state `Content-Type` to accept.
public protocol BodyParametersType {
    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    var contentType: String { get }

    /// Builds `RequestBodyEntity`.
    /// Throws: `ErrorType`
    func buildEntity() throws -> RequestBodyEntity
}
