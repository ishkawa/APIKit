import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK
import LlamaKit
#endif

public enum ResponseBodyParser {
    case JSON(NSJSONReadingOptions)
    case URL(NSStringEncoding)
    case Custom(NSData -> Result<AnyObject, NSError>)

    public func parseData(data: NSData) -> Result<AnyObject, NSError> {
        var result: Result<AnyObject, NSError>

        switch self {
        case .JSON(let readingOptions):
            var error: NSError?
            if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: readingOptions, error: &error) {
                result = Result.Success(Box(object))
            } else {
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            var error: NSError?
            if let object: AnyObject = URLEncodedSerialization.objectFromData(data, encoding: encoding, error: &error) {
                result = Result.Success(Box(object))
            } else {
                result = Result.Failure(Box(error!))
            }

        case .Custom(let parseData):
            result = parseData(data)
        }

        return result
    }
}
