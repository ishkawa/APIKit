import Foundation

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest? { get }
    
    class func responseFromObject(object: AnyObject) -> Response?
}
