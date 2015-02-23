import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK
import LlamaKit
#endif

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

    public func parseData(data: NSData) -> Result<AnyObject, NSError> {
        var result: Result<AnyObject, NSError>

        switch self {
        case .JSON(let readingOptions):
            var error: NSError?
            if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: readingOptions, error: &error) {
                result = success(object)
            } else {
                result = failure(error!)
            }

        case .URL(let encoding):
            var error: NSError?
            if let object: AnyObject = URLEncodedSerialization.objectFromData(data, encoding: encoding, error: &error) {
                result = success(object)
            } else {
                result = failure(error!)
            }

        case .Custom(let (accept, parseData)):
            result = parseData(data)
        }

        return result
    }
    
    
}
