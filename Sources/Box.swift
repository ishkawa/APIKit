import Foundation

internal final class Box<T> {
    let value: T

    init(_ value: T) {
        self.value = value
    }
}
