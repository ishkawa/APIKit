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
    
    class func sendRequest<T : APIKit.Request>(request: T, handler: (Result<T.Response, NSError>) -> Void = { r in }) {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request.URLRequest) { data, URLResponse, connectionError in
            let mainQueue = dispatch_get_main_queue()

            if let error = connectionError {
                dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                return
            }

            var parseError: NSError?
            let JSONObject: AnyObject! = NSJSONSerialization.JSONObjectWithData(data,
                options: nil,
                error: &parseError)

            if let error = parseError {
                dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                return
            }

            let statusCode = (URLResponse as? NSHTTPURLResponse)?.statusCode
            switch (statusCode, request.responseFromObject(JSONObject)) {
            case (.Some(200..<300), .Some(let response)):
                dispatch_async(mainQueue, { handler(.Success(Box(response))) })

            default:
                let userInfo = [NSLocalizedDescriptionKey: "unresolved error occurred."]
                let error = NSError(domain: "GitHubErrorDomain", code: 0, userInfo: userInfo)
                dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
            }
        }
        
        task.resume()
    }
}
