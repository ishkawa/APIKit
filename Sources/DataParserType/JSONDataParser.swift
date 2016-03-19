import Foundation

/// `JSONDataParser` response JSON data.
public class JSONDataParser: DataParserType {
    public let readingOptions: NSJSONReadingOptions

    public init(readingOptions: NSJSONReadingOptions) {
        self.readingOptions = readingOptions
    }

    // MARK: DataParserType
    public var contentType: String? {
        return "application/json"
    }

    public func parseData(data: NSData) throws -> AnyObject {
        guard data.length > 0 else {
            return [:]
        }

        return try NSJSONSerialization.JSONObjectWithData(data, options: readingOptions)
    }
}
