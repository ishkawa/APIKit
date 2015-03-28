import Foundation

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest? { get }
    
    func responseFromObject(object: AnyObject) -> Response?
}
