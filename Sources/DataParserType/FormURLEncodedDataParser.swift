import Foundation

/// `FormURLEncodedDataParser` parses form URL encoded response data.
public class FormURLEncodedDataParser: DataParserType {
    public enum Error: ErrorType {
        case CannotGetStringFromData(NSData)
    }

    /// The string encoding of the data.
    public let encoding: NSStringEncoding

    /// Returns `FormURLEncodedDataParser` with the string encoding.
    public init(encoding: NSStringEncoding) {
        self.encoding = encoding
    }

    // MARK: - DataParserType

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }

    /// Return `AnyObject` that expresses structure of response.
    /// - Throws: `FormURLEncodedDataParser.Error` when the parser fails to initialize `NSString` from `NSData`.
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
