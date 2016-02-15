import Foundation
import Result

public enum RequestBodyBuilder {
    case JSON(writingOptions: NSJSONWritingOptions)
    case FormURLEncoded(encoding: NSStringEncoding)
    case Custom(builder: AnyObject throws -> RequestBody)

    /// - Throws: NSError, URLEncodedSerialization.Error, ErrorType
    public func buildRequestBodyFromObject(object: AnyObject) throws -> RequestBody {
        switch self {
        case .JSON(let writingOptions):
            // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
            guard NSJSONSerialization.isValidJSONObject(object) else {
                throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
            }

            let data = try NSJSONSerialization.dataWithJSONObject(object, options: writingOptions)
            return RequestBody(entity: .Data(data), contentType: "application/json")

        case .FormURLEncoded(let encoding):
            let data = try URLEncodedSerialization.dataFromObject(object, encoding: encoding)
            return RequestBody(entity: .Data(data), contentType: "application/x-www-form-urlencoded")

        case .Custom(let builder):
            return try builder(object)
        }
    }
}
