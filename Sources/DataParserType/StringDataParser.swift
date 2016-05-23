import Foundation

/// `StringDataParser` parses data and convert it to string.
public class StringDataParser: DataParserType {
    public enum Error: ErrorType {
        case InvalidData(NSData)
    }

    /// The string encoding of the data.
    public let encoding: NSStringEncoding

    /// Returns `FormURLEncodedDataParser` with the string encoding.
    public init(encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.encoding = encoding
    }

    // MARK: - DataParserType

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return nil
    }

    /// Return `String` that converted from `NSData`.
    /// - Throws: `StringDataParser.Error` when the parser fails to initialize `NSString` from `NSData`.
    public func parseData(data: NSData) throws -> AnyObject {
        guard let string = NSString(data: data, encoding: encoding) else {
            throw Error.InvalidData(data)
        }

        return string
    }
}
