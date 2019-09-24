import Foundation

/// `JSONBodyParameters` serializes JSON object for HTTP body and states its content type is JSON.
public struct JSONBodyParameters: BodyParameters {
    /// The JSON object to be serialized.
    public let JSONObject: Any

    /// The writing options for serialization.
    public let writingOptions: JSONSerialization.WritingOptions

    /// Returns `JSONBodyParameters` that is initialized with JSON object and writing options.
    public init(JSONObject: Any, writingOptions: JSONSerialization.WritingOptions = []) {
        self.JSONObject = JSONObject
        self.writingOptions = writingOptions
    }

    // MARK: - BodyParameters

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/json"
    }

    /// Builds `RequestBodyEntity.data` that represents `JSONObject`.
    /// - Throws: `NSError` if `JSONSerialization` fails to serialize `JSONObject`.
    public func buildEntity() throws -> RequestBodyEntity {
        // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
        guard JSONSerialization.isValidJSONObject(JSONObject) else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
        }

        return .data(try JSONSerialization.data(withJSONObject: JSONObject, options: writingOptions))
    }
}

extension JSONBodyParameters: ExpressibleByDictionaryLiteral {
    public typealias Key = String
    public typealias Value = Any

    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(JSONObject: Dictionary(uniqueKeysWithValues: elements))
    }
}
