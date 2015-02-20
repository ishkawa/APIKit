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
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            var error: NSError?
            if let data = URLEncodedSerialization.dataFromObject(object, encoding: encoding, error: &error) {
                result = Result.Success(Box(data))
            } else {
                result = Result.Failure(Box(error!))
            }

        case .Custom(let buildBodyFromObject):
            result = buildBodyFromObject(object)
        }

        return result
    }
}
