import Foundation

/// `URLEncodedQueryParameters` serializes form object for HTTP URL query.
public struct URLEncodedQueryParameters: QueryParameters {
    /// The parameters to be url encoded.
    public let parameters: Any

    /// Returns `URLEncodedQueryParameters` that is initialized with parameters.
    public init(parameters: Any) {
        self.parameters = parameters
    }

    /// Generate url encoded `String`.
    public func encode() -> String? {
        guard let parameters = parameters as? [String: Any], !parameters.isEmpty else {
            return nil
        }
        return URLEncodedSerialization.string(from: parameters)
    }
}
