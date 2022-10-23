import Foundation

/// `ProtobufDataParser` response Data data.
public class ProtobufDataParser: DataParser {
    /// Returns `ProtobufDataParser`.
    public init() {}
    
    // MARK: - DataParser
    
    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/protobuf"
    }
    
    /// Return `Data` that expresses structure of Data response.
    public func parse(data: Data) throws -> Data {
        return data
    }
}
