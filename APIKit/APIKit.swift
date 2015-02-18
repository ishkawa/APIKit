import Foundation
import LlamaKit

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest { get }
    
    func responseFromObject(object: AnyObject) -> Response?
}

public protocol API {
    class func sendRequest<T: Request>(request: T, handler: (Result<T.Response, NSError>) -> Void)
}
