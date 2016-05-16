import Foundation

/// `StringDataParser` parses data and convert it to string.
public class StringDataParser: DataParserType {
    public enum Error: ErrorType {
        case InvalidData(NSData)
    }

    public let encoding: NSStringEncoding

    public init(encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.encoding = encoding
    }

    // MARK: DataParserType
    public var contentType: String? {
        return nil
    }

    public func parseData(data: NSData) throws -> AnyObject {
        guard let string = NSString(data: data, encoding: encoding) else {
            throw Error.InvalidData(data)
        }

        return string
    }
}