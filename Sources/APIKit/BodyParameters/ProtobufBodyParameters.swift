import Foundation

/// `ProtobufBodyParameters` serializes Protobuf object for HTTP body and states its content type is Protobuf.
public struct ProtobufBodyParameters: BodyParameters {
    /// The Protobuf object to be serialized.
    public let protobufObject: Data
    
    /// Returns `ProtobufBodyParameters`.
    public init(protobufObject: Data) {
        self.protobufObject = protobufObject
    }

    // MARK: - BodyParameters

    /// `Content-Type` to send. The value for this property will be set to `Accept` HTTP header field.
    public var contentType: String {
        return "application/protobuf"
    }

    /// Builds `RequestBodyEntity.data` that represents `ProtobufObject`.
    public func buildEntity() throws -> RequestBodyEntity {
        return .data(protobufObject)
    }
}
