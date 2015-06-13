import Foundation
import Result

public enum ResponseBodyParser {
    case JSON(readingOptions: NSJSONReadingOptions)
    case URL(encoding: NSStringEncoding)
    case Custom(acceptHeader: String, parseData: NSData -> Result<AnyObject, NSError>)
    
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

    // TODO: migrate to Swift 2 style error handling
    public func parseData(data: NSData) -> Result<AnyObject, NSError> {
        switch self {
        case .JSON(let readingOptions):
            if data.length == 0 {
                return .success([:])
            }

            let result: Result<AnyObject, NSError>
            do {
                result = .success(try NSJSONSerialization.JSONObjectWithData(data, options: readingOptions))
            } catch {
                result = .failure(error as NSError)
            }

            return result

        case .URL(let encoding):
            let result: Result<AnyObject, NSError>
            do {
                result = .success(try URLEncodedSerialization.objectFromData(data, encoding: encoding))
            } catch {
                result = .failure(error as NSError)
            }

            return result

        case .Custom(let (_, parseData)):
            return parseData(data)
        }
    }
}
