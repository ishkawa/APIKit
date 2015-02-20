import Foundation
import LlamaKit

public let APIKitRequestBodyBuidlerErrorDomain = "APIKitRequestBodyBuidlerErrorDomain"

public enum RequestBodyBuilder {
    case JSON(NSJSONWritingOptions)
    case URL(NSStringEncoding)
    case Custom(AnyObject -> Result<NSData, NSError>)

    public func buildBodyFromObject(object: AnyObject) -> Result<NSData, NSError> {
        var result: Result<NSData, NSError>

        switch self {
        case .JSON(let writingOptions):
            if !NSJSONSerialization.isValidJSONObject(object) {
                let userInfo = [NSLocalizedDescriptionKey: "invalidate object for JSON passed."]
                let error = NSError(domain: APIKitRequestBodyBuidlerErrorDomain, code: 0, userInfo: userInfo)
                result = Result.Failure(Box(error))
                break
            }
            
            var error: NSError?
            if let data = NSJSONSerialization.dataWithJSONObject(object, options: writingOptions, error: &error) {
                result = Result.Success(Box(data))
            } else {
                // According to doc of NSJSONSerialization, error must occur if return value is nil.
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            var queryItems = [NSURLQueryItem]()
            
            if let dictionary = object as? [String: AnyObject] {
                for (key, value) in dictionary {
                    let string = (value as? String) ?? "\(value)"
                    let queryItem = NSURLQueryItem(name: key, value: string)
                    queryItems.append(queryItem)
                }
            }
            
            let components = NSURLComponents()
            components.queryItems = queryItems
            
            if let data = components.query?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                result = Result.Success(Box(data))
            } else {
                let userInfo = [NSLocalizedDescriptionKey: "failed to create url encoded dictionary."]
                let error = NSError(domain: APIKitRequestBodyBuidlerErrorDomain, code: 0, userInfo: userInfo)
                result = Result.Failure(Box(error))
            }

        case .Custom(let buildBodyFromObject):
            result = buildBodyFromObject(object)
        }

        return result
    }
}
