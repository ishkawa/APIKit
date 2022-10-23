import Foundation

/// `DecodableJSONDataParser` response Data data.
public class DecodableJSONDataParser: DataParser {
    /// Returns `DecodableJSONDataParser`.
    public init() {}

    // MARK: - DataParser

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/json"
    }

    /// Return `Data` that expresses structure of Data response.
    public func parse(data: Data) throws -> Data {
        return data
    }
}
