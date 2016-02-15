import Foundation

public class RequestBody {
    public enum Entity {
        case Data(NSData)
        case InputStream(NSInputStream)
    }

    public let entity: Entity
    public let contentType: String

    public init(entity: Entity, contentType: String) {
        self.entity = entity
        self.contentType = contentType
    }
}
