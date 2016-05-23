import Foundation

/// `JSONDataParser` response JSON data.
public class JSONDataParser: DataParserType {
    /// Options for reading the JSON data and creating the objects.
    public let readingOptions: NSJSONReadingOptions

    /// Returns `JSONDataParser` with the reading options.
    public init(readingOptions: NSJSONReadingOptions) {
        self.readingOptions = readingOptions
    }

    // MARK: - DataParserType

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/json"
    }

    /// Return `AnyObject` that expresses structure of JSON response.
    /// - Throws: `NSError` when `NSJSONSerialization` fails to deserialize `NSData` into `AnyObject`.
    public func parseData(data: NSData) throws -> AnyObject {
        guard data.length > 0 else {
            return [:]
        }

        return try NSJSONSerialization.JSONObjectWithData(data, options: readingOptions)
    }
}
