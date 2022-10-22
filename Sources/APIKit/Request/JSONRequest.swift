import Foundation

public protocol JSONRequest: Request {}

public extension JSONRequest {
    var dataParser: JSONDataParser {
        return JSONDataParser(readingOptions: [])
    }
}
