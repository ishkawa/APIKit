import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK
import LlamaKit
#endif

public let APIKitRequestBodyBuidlerErrorDomain = "APIKitRequestBodyBuidlerErrorDomain"

public enum RequestBodyBuilder {
    case JSON(writingOptions: NSJSONWritingOptions)
    case URL(encoding: NSStringEncoding)
    case Custom(contentTypeHeader: String, buildBodyFromObject: AnyObject -> Result<NSData, NSError>)
    
    public var contentTypeHeader: String {
        switch self {
        case .JSON:
            return "application/json"
            
        case .URL:
            return "application/x-www-form-urlencoded"
            
        case .Custom(let (type, _)):
            return type
        }
    }

    public func buildBodyFromObject(object: AnyObject) -> Result<NSData, NSError> {
        var result: Result<NSData, NSError>

        switch self {
        case .JSON(let writingOptions):
            if !NSJSONSerialization.isValidJSONObject(object) {
                let userInfo = [NSLocalizedDescriptionKey: "invalid object for JSON passed."]
                let error = NSError(domain: APIKitRequestBodyBuidlerErrorDomain, code: 0, userInfo: userInfo)
                result = Result.Failure(Box(error))
                break
            }
            
            var error: NSError?
            if let data = NSJSONSerialization.dataWithJSONObject(object, options: writingOptions, error: &error) {
                result = Result.Success(Box(data))
            } else {
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            var error: NSError?
            if let data = URLEncodedSerialization.dataFromObject(object, encoding: encoding, error: &error) {
                result = Result.Success(Box(data))
            } else {
                result = Result.Failure(Box(error!))
            }

        case .Custom(let (_, buildBodyFromObject)):
            result = buildBodyFromObject(object)
        }

        return result
    }
}
