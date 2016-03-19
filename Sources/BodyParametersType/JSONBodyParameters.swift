import Foundation

/// `JSONBodyParameters` serializes JSON object for HTTP body and states its content type is JSON.
public struct JSONBodyParameters: BodyParametersType {
    /// The JSON object to be serialized.
    public let JSONObject: AnyObject

    /// The writing options for serialization.
    public let writingOptions: NSJSONWritingOptions

    /// Returns `JSONBodyParameters` that is initialized with JSON object and writing options.
    public init(JSONObject: AnyObject, writingOptions: NSJSONWritingOptions = []) {
        self.JSONObject = JSONObject
        self.writingOptions = writingOptions
    }

    // MARK: BodyParametersType
    public var contentType: String {
        return "application/json"
    }

    /// Builds `RequestBodyEntity.Data` that represents `JSONObject`.
    /// - Throws: `NSError` if `NSJSONSerialization` fails to serialize `JSONObject`.
    public func buildEntity() throws -> RequestBodyEntity {
        // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
        guard NSJSONSerialization.isValidJSONObject(JSONObject) else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
        }

        return .Data(try NSJSONSerialization.dataWithJSONObject(JSONObject, options: writingOptions))
    }
}
