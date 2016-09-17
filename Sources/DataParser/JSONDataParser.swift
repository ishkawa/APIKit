import Foundation

/// `JSONDataParser` response JSON data.
public class JSONDataParser: DataParser {
    /// Options for reading the JSON data and creating the objects.
    public let readingOptions: JSONSerialization.ReadingOptions

    /// Returns `JSONDataParser` with the reading options.
    public init(readingOptions: JSONSerialization.ReadingOptions) {
        self.readingOptions = readingOptions
    }

    // MARK: - DataParser

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/json"
    }

    /// Return `Any` that expresses structure of JSON response.
    /// - Throws: `NSError` when `JSONSerialization` fails to deserialize `Data` into `Any`.
    public func parse(data: Data) throws -> Any {
        guard data.count > 0 else {
            return [:]
        }

        return try JSONSerialization.jsonObject(with: data, options: readingOptions)
    }
}
