import Foundation
import Result

public enum RequestBodyBuilder {
    case JSON(writingOptions: NSJSONWritingOptions)
    case URL(encoding: NSStringEncoding)
    case MultipartFormData
    case Custom(contentTypeHeader: String, buildBodyFromObject: AnyObject throws -> NSData)

    /// - Throws: NSError, URLEncodedSerialization.Error, ErrorType
    public func buildBodyFromObject(object: AnyObject) throws -> (contentTypeHeader: String, body: NSData) {
        switch self {
        case .JSON(let writingOptions):
            // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
            guard NSJSONSerialization.isValidJSONObject(object) else {
                throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
            }
            return ("application/json", try NSJSONSerialization.dataWithJSONObject(object, options: writingOptions))

        case .URL(let encoding):
            return ("application/x-www-form-urlencoded", try URLEncodedSerialization.dataFromObject(object, encoding: encoding))

        case .MultipartFormData:
            let (boundary, body) = try MultipartFormDataSerialization.dataFromObject(object)
            return ("multipart/form-data; boundary=\(boundary)", body)
        case .Custom(let (contentTypeHeader, buildBodyFromObject)):
            return (contentTypeHeader, try buildBodyFromObject(object))
        }
    }
}
