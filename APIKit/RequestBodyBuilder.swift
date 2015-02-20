import Foundation
import LlamaKit

public enum RequestBodyBuilder {
    case JSON(NSJSONWritingOptions)
    case URL(NSStringEncoding)
    case Custom(AnyObject -> Result<NSData, NSError>)

    public func buildBodyFromObject(object: AnyObject) -> Result<NSData, NSError> {
        var result: Result<NSData, NSError>

        switch self {
        case .JSON(let writingOptions):
            var error: NSError?
            if let data = NSJSONSerialization.dataWithJSONObject(object, options: writingOptions, error: &error) {
                result = Result.Success(Box(data))
            } else {
                // According to doc of NSJSONSerialization, error must occur if return value is nil.
                result = Result.Failure(Box(error!))
            }

        case .URL(let encoding):
            // FIXME:
            result = Result.Success(Box(NSData()))

        case .Custom(let encode):
            result = encode(object)
        }

        return result
    }
}
