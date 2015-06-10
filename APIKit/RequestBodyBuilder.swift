import Foundation
import Result

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

    // TODO: migrate to Swift 2 style error handling
    public func buildBodyFromObject(object: AnyObject) -> Result<NSData, NSError> {
        switch self {
        case .JSON(let writingOptions):
            if !NSJSONSerialization.isValidJSONObject(object) {
                let userInfo = [NSLocalizedDescriptionKey: "invalid object for JSON passed."]
                let error = NSError(domain: APIKitRequestBodyBuidlerErrorDomain, code: 0, userInfo: userInfo)
                return .failure(error)
            }

            let result: Result<NSData, NSError>
            do {
                result = .success(try NSJSONSerialization.dataWithJSONObject(object, options: writingOptions))
            } catch {
                result = .failure(error as NSError)
            }

            return result

        case .URL(let encoding):
            return `try` { error in
                return URLEncodedSerialization.dataFromObject(object, encoding: encoding, error: error)
            }

        case .Custom(let (_, buildBodyFromObject)):
            return buildBodyFromObject(object)
        }
    }
}
