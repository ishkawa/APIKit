import Foundation

/// `FormURLEncodedBodyParameters` serializes form object for HTTP body and states its content type is form.
public struct FormURLEncodedBodyParameters: BodyParameters {
    /// The form object to be serialized.
    public let form: [String: Any]

    /// The string encoding of the serialized form.
    public let encoding: String.Encoding

    /// Returns `FormURLEncodedBodyParameters` that is initialized with form object and encoding.
    public init(formObject: [String: Any], encoding: String.Encoding = .utf8) {
        self.form = formObject
        self.encoding = encoding
    }

    // MARK: - BodyParameters

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    /// Builds `RequestBodyEntity.data` that represents `form`.
    /// - Throws: `URLEncodedSerialization.Error` if `URLEncodedSerialization` fails to serialize form object.
    public func buildEntity() throws -> RequestBodyEntity {
        return .data(try URLEncodedSerialization.data(from: form, encoding: encoding))
    }
}
