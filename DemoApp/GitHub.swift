import Foundation
import APIKit
import LlamaKit

class GitHub: API {
    enum Method: String {
        case GET = "GET"
        case POST = "POST"
    }
    
    class URLRequest: NSMutableURLRequest {
        let scheme = "https"
        let host = "api.github.com"
        
        convenience init(_ method: Method, _ path: String, _ parameters: [String: AnyObject] = [:]) {
            self.init()
            
            let components = NSURLComponents()
            
            switch method {
            case .GET:
                // TODO: escape values
                components.query = join("&", parameters.keys.map({ "\($0)=\(parameters[$0]!)" })) as String
                
            case .POST:
                HTTPBody = NSJSONSerialization.dataWithJSONObject(parameters, options: nil, error: nil)
            }
            
            components.scheme = scheme
            components.host = host
            components.path = path
            
            URL = components.URL
            HTTPMethod = method.rawValue
            setValue("application/json", forHTTPHeaderField: "Accept")
        }
    }
}
