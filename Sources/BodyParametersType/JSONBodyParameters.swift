import Foundation

public struct JSONBodyParameters: BodyParametersType {
    public let JSONObject: AnyObject
    public let writingOptions: NSJSONWritingOptions

    public init(JSONObject: AnyObject, writingOptions: NSJSONWritingOptions = []) {
        self.JSONObject = JSONObject
        self.writingOptions = writingOptions
    }

    // MARK: BodyParametersType
    public var contentType: String {
        return "application/json"
    }

    public func buildEntity() throws -> RequestBodyEntity {
        // If isValidJSONObject(_:) is false, dataWithJSONObject(_:options:) throws NSException.
        guard NSJSONSerialization.isValidJSONObject(JSONObject) else {
            throw NSError(domain: NSCocoaErrorDomain, code: 3840, userInfo: nil)
        }

        return .Data(try NSJSONSerialization.dataWithJSONObject(JSONObject, options: writingOptions))
    }
}
