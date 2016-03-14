import Foundation

public enum RequestBodyEntity {
    case Data(NSData)
    case InputStream(NSInputStream)
}

public protocol BodyParametersType {
    var contentType: String { get }

    func buildEntity() throws -> RequestBodyEntity
}
