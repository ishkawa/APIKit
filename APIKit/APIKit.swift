import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK
import LlamaKit
#endif

public let APIKitErrorDomain = "APIKitErrorDomain"

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest? { get }
    
    func responseFromObject(object: AnyObject) -> Response?
}

public enum Method: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case DELETE = "DELETE"
    case PATCH = "PATCH"
    case TRACE = "TRACE"
    case OPTIONS = "OPTIONS"
    case CONNECT = "CONNECT"
}

public class API {
    // configurations
    public class func baseURL() -> NSURL {
        return NSURL()
    }

    public class func URLSession() -> NSURLSession {
        return NSURLSession.sharedSession()
    }

    public class func requestBodyBuilder() -> RequestBodyBuilder {
        return .JSON(writingOptions: nil)
    }

    public class func responseBodyParser() -> ResponseBodyParser {
        return .JSON(readingOptions: nil)
    }

    // build NSURLRequest
    public class func URLRequest(method: Method, _ path: String, _ parameters: [String: AnyObject] = [:]) -> NSURLRequest? {
        if let components = NSURLComponents(URL: baseURL(), resolvingAgainstBaseURL: true) {
            let request = NSMutableURLRequest()
            
            switch method {
            case .GET, .HEAD, .DELETE:
                components.query = URLEncodedSerialization.stringFromObject(parameters, encoding: NSUTF8StringEncoding)
                
            default:
                switch requestBodyBuilder().buildBodyFromObject(parameters) {
                case .Success(let box):
                    request.HTTPBody = box.unbox
                    
                case .Failure(let box):
                    return nil
                }
            }
            
            components.path = (components.path ?? "").stringByAppendingPathComponent(path)
            request.URL = components.URL
            request.HTTPMethod = method.rawValue
            request.setValue(requestBodyBuilder().contentTypeHeader, forHTTPHeaderField: "Content-Type")
            request.setValue(responseBodyParser().acceptHeader, forHTTPHeaderField: "Accept")
            
            return request
        } else {
            return nil
        }
    }

    // send request and build response object
    public class func sendRequest<T: Request>(request: T, handler: (Result<T.Response, NSError>) -> Void = {r in}) {
        let session = URLSession()
        let mainQueue = dispatch_get_main_queue()
        
        if let URLRequest = request.URLRequest {
            let task = session.dataTaskWithRequest(URLRequest) { data, URLResponse, connectionError in
                if let error = connectionError {
                    dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                    return
                }
                
                let statusCode = (URLResponse as? NSHTTPURLResponse)?.statusCode ?? 0
                if !contains(200..<300, statusCode) {
                    let userInfo = [NSLocalizedDescriptionKey: "received status code that represents error"]
                    let error = NSError(domain: APIKitErrorDomain, code: statusCode, userInfo: userInfo)
                    dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                    return
                }

                let mappedResponse: Result<T.Response, NSError> = self.responseBodyParser().parseData(data).flatMap { rawResponse in
                    if let response = request.responseFromObject(rawResponse) {
                        return success(response)
                    } else {
                        let userInfo = [NSLocalizedDescriptionKey: "failed to create model object from raw object."]
                        let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
                        return failure(error)
                    }

                }
                dispatch_async(mainQueue, { handler(mappedResponse) })
            }
            
            task.resume()            
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "failed to build request."]
            let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
            dispatch_async(mainQueue, { handler(failure(error)) })
        }
    }
}
