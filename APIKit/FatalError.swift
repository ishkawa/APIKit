import Foundation

public struct FatalError: ErrorType {
    public let message: String

    public init(_ message: String) {
        self.message = message
    }
}
