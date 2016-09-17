import Foundation

/// `RequestBodyEntity` represents entity of HTTP body.
public enum RequestBodyEntity {
    /// Expresses entity as `Data`. The associated value will be set to `URLRequest.httpBody`.
    case data(Data)

    /// Expresses entity as `InputStream`. The associated value will be set to `URLRequest.httpBodyStream`.
    case inputStream(InputStream)
}

/// `BodyParameters` provides interface to parse HTTP response body and to state `Content-Type` to accept.
public protocol BodyParameters {
    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    var contentType: String { get }

    /// Builds `RequestBodyEntity`.
    /// Throws: `ErrorType`
    func buildEntity() throws -> RequestBodyEntity
}
