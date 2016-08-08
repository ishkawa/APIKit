import Foundation

/// `FormURLEncodedBodyParameters` serializes form object for HTTP body and states its content type is form.
public struct FormURLEncodedBodyParameters: BodyParametersType {
    /// The form object to be serialized.
    public let form: [String: AnyObject]

    /// The string encoding of the serialized form.
    public let encoding: String.Encoding

    /// Returns `FormURLEncodedBodyParameters` that is initialized with form object and encoding.
    public init(formObject: [String: AnyObject], encoding: String.Encoding = .utf8) {
        self.form = formObject
        self.encoding = encoding
    }

    // MARK: - BodyParametersType

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    /// Builds `RequestBodyEntity.Data` that represents `form`.
    /// - Throws: `URLEncodedSerialization.Error` if `URLEncodedSerialization` fails to serialize form object.
    public func buildEntity() throws -> RequestBodyEntity {
        return .Data(try URLEncodedSerialization.dataFromObject(form, encoding: encoding))
    }
}
