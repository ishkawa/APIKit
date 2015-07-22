import Foundation
import Result

public enum RequestBodyBuilder {
    case JSON(writingOptions: NSJSONWritingOptions)
    case URL(encoding: NSStringEncoding)
    case Custom(contentTypeHeader: String, buildBodyFromObject: AnyObject throws -> NSData)
    
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

    /// - Throws: NSError, URLEncodedSerialization.Error, ErrorType
    public func buildBodyFromObject(object: AnyObject) throws -> NSData {
        switch self {
        case .JSON(let writingOptions):
            // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
            guard NSJSONSerialization.isValidJSONObject(object) else {
                throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
            }
            return try NSJSONSerialization.dataWithJSONObject(object, options: writingOptions)

        case .URL(let encoding):
            return try URLEncodedSerialization.dataFromObject(object, encoding: encoding)

        case .Custom(let (_, buildBodyFromObject)):
            return try buildBodyFromObject(object)
        }
    }
}
