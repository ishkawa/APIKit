import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK || COCOAPODS
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
        switch self {
        case .JSON(let writingOptions):
            if !NSJSONSerialization.isValidJSONObject(object) {
                let userInfo = [NSLocalizedDescriptionKey: "invalid object for JSON passed."]
                let error = NSError(domain: APIKitRequestBodyBuidlerErrorDomain, code: 0, userInfo: userInfo)
                return failure(error)
            }

            return try({ error in
                return NSJSONSerialization.dataWithJSONObject(object, options: writingOptions, error: error)
            })

        case .URL(let encoding):
            return try ({ error in
                return URLEncodedSerialization.dataFromObject(object, encoding: encoding, error: error)
            })

        case .Custom(let (_, buildBodyFromObject)):
            return buildBodyFromObject(object)
        }
    }
}
