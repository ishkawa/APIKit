import Foundation

/// `FormURLEncodedDataParser` parses form URL encoded response data.
public class FormURLEncodedDataParser: DataParser {
    public enum Error: Swift.Error {
        case cannotGetStringFromData(Data)
    }

    /// The string encoding of the data.
    public let encoding: String.Encoding

    /// Returns `FormURLEncodedDataParser` with the string encoding.
    public init(encoding: String.Encoding) {
        self.encoding = encoding
    }

    // MARK: - DataParser

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/x-www-form-urlencoded"
    }

    /// Return `Any` that expresses structure of response.
    /// - Throws: `FormURLEncodedDataParser.Error` when the parser fails to initialize `String` from `Data`.
    public func parse(data: Data) throws -> Any {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.cannotGetStringFromData(data)
        }

        var components = URLComponents()
        components.percentEncodedQuery = string

        let queryItems = components.queryItems ?? []
        var dictionary = [String: Any]()

        for queryItem in queryItems {
            dictionary[queryItem.name] = queryItem.value
        }

        return dictionary
    }
}
