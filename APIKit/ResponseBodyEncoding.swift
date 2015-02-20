import Foundation
import LlamaKit

public enum ResponseBodyEncoding {
    case JSON(NSJSONReadingOptions)
    case URL(NSStringEncoding)
    case Custom(NSData -> Result<AnyObject, NSError>)

    public func decode(data: NSData) -> Result<AnyObject, NSError> {
        var result: Result<AnyObject, NSError>

        switch self {
        case .JSON(let readingOptions):
            var error: NSError?
            if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: readingOptions, error: &error) {
                result = Result.Success(Box(object))
            } else {
                // According to doc of NSJSONSerialization, error must occur if return value is nil.
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            var dictionary = [String: AnyObject]()

            if let string = NSString(data: data, encoding: encoding) as? String {
                let URLComponents = NSURLComponents()
                URLComponents.query = string

                if let queryItems = URLComponents.queryItems as? [NSURLQueryItem] {
                    for queryItem in queryItems {
                        dictionary[queryItem.name] = queryItem.value
                    }
                }
            }

            result = Result.Success(Box(dictionary))

        case .Custom(let decode):
            result = decode(data)
        }

        return result
    }
}
