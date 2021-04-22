import Foundation

/// `QueryParameters` provides interface to generate HTTP URL query strings.
public protocol QueryParameters {
    /// Generate URL query strings.
    func encode() -> String?
}
