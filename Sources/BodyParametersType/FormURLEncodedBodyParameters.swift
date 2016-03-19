import Foundation

public struct FormURLEncodedBodyParameters: BodyParametersType {
    public enum Error: ErrorType {
        case InvalidQueryItems([NSURLQueryItem])
        case InvalidEncodedQuery(String)
    }

    public let form: [String: AnyObject]
    public let encoding: NSStringEncoding

    public init(formObject: [String: AnyObject], encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.form = formObject
        self.encoding = encoding
    }

    // MARK: BodyParametersType
    public var contentType: String {
        return "application/x-www-form-urlencoded"
    }

    public func buildEntity() throws -> RequestBodyEntity {
        return .Data(try URLEncodedSerialization.dataFromObject(form, encoding: encoding))
    }
}
