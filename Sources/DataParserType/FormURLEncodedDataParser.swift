import Foundation

/// `FormURLEncodedDataParser` parses form URL encoded response data.
public class FormURLEncodedDataParser: DataParserType {
    public enum Error: ErrorType {
        case CannotGetStringFromData(NSData)
    }

    public let encoding: NSStringEncoding

    public init(encoding: NSStringEncoding) {
        self.encoding = encoding
    }

    // MARK: DataParserType
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }

    public func parseData(data: NSData) throws -> AnyObject {
        guard let string = NSString(data: data, encoding: encoding) as? String else {
            throw Error.CannotGetStringFromData(data)
        }

        let components = NSURLComponents()
        components.percentEncodedQuery = string

        let queryItems = components.queryItems ?? []
        var dictionary = [String: AnyObject]()

        for queryItem in queryItems {
            dictionary[queryItem.name] = queryItem.value
        }

        return dictionary
    }
}
