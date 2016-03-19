import Foundation

/// `FormURLEncodedBodyParameters` serializes form object for HTTP body and states its content type is form.
public struct FormURLEncodedBodyParameters: BodyParametersType {
    /// The form object to be serialized.
    public let form: [String: AnyObject]
    
    /// The string encoding of the serialized form.
    public let encoding: NSStringEncoding

    /// Returns `FormURLEncodedBodyParameters` that is initialized with form object and encoding.
    public init(formObject: [String: AnyObject], encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.form = formObject
        self.encoding = encoding
    }

    // MARK: BodyParametersType
    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    /// Builds `RequestBodyEntity.Data` that represents `form`.
    /// - Throws: `URLEncodedSerialization.Error` if `URLEncodedSerialization` fails to serialize form object.
    public func buildEntity() throws -> RequestBodyEntity {
        return .Data(try URLEncodedSerialization.dataFromObject(form, encoding: encoding))
    }
}
