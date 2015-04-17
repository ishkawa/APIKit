import Foundation

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest? { get }
    
    static func responseFromObject(object: AnyObject) -> Response?
}
