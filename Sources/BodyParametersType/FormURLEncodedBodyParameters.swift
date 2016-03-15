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
        let queryItems = form.map { key, value -> NSURLQueryItem in
            if let string = value as? String {
                return NSURLQueryItem(name: key, value: string)
            } else {
                return NSURLQueryItem(name: key, value: "\(value)")
            }
        }

        let components = NSURLComponents()
        components.queryItems = queryItems

        guard let encodedQuery = components.percentEncodedQuery else {
            throw Error.InvalidQueryItems(queryItems)
        }

        guard let data = encodedQuery.dataUsingEncoding(encoding) else {
            throw Error.InvalidEncodedQuery(encodedQuery)
        }

        return .Data(data)
    }
}
