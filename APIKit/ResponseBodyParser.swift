import Foundation
import Result

public enum ResponseBodyParser {
    case JSON(readingOptions: NSJSONReadingOptions)
    case URL(encoding: NSStringEncoding)
    case Custom(acceptHeader: String, parseData: NSData throws -> AnyObject)
    
    public var acceptHeader: String {
        switch self {
        case .JSON:
            return "application/json"
            
        case .URL:
            return "application/x-www-form-urlencoded"
            
        case .Custom(let (type, _)):
            return type
        }
    }

    /// - Throws: NSError, URLEncodedSerialization.Error, ErrorType
    public func parseData(data: NSData) throws -> AnyObject {
        switch self {
        case .JSON(let readingOptions):
            if data.length == 0 {
                return [:]
            }
            return try NSJSONSerialization.JSONObjectWithData(data, options: readingOptions)

        case .URL(let encoding):
            return try URLEncodedSerialization.objectFromData(data, encoding: encoding)

        case .Custom(let (_, parseData)):
            return try parseData(data)
        }
    }
}
