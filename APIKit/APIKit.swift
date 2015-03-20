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

private var taskRequestKey = 0
private var dataTaskResponseBufferKey = 0
private var dataTaskCompletionHandlerKey = 0

private extension NSURLSessionTask {
    // - `var request: Request?` is not available in both of Swift 1.1 and 1.2 ("protocol can only be used as a generic constraint")
    // - `var request: Any?` is not available in Swift 1.1 (Swift compliler fails with segmentation fault)
    // so Box<Any>? is used here for now
    private var request: Box<Any>? {
        get {
            return objc_getAssociatedObject(self, &taskRequestKey) as? Box<Any>
        }
        
        set {
            if let value = newValue {
                objc_setAssociatedObject(self, &taskRequestKey, value, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            } else {
                objc_setAssociatedObject(self, &taskRequestKey, nil, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
}

private extension NSURLSessionDataTask {
    private var responseBuffer: NSMutableData {
        if let responseBuffer = objc_getAssociatedObject(self, &dataTaskResponseBufferKey) as? NSMutableData {
            return responseBuffer
        } else {
            let responseBuffer = NSMutableData()
            objc_setAssociatedObject(self, &dataTaskResponseBufferKey, responseBuffer, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return responseBuffer
        }
    }
    
    private var completionHandler: ((NSData, NSURLResponse?, NSError?) -> Void)? {
        get {
            return (objc_getAssociatedObject(self, &dataTaskCompletionHandlerKey) as? Box<(NSData, NSURLResponse?, NSError?) -> Void>)?.unbox
        }
        
        set {
            if let value = newValue  {
                objc_setAssociatedObject(self, &dataTaskCompletionHandlerKey, Box(value), UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            } else {
                objc_setAssociatedObject(self, &dataTaskCompletionHandlerKey, nil, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            }
        }
    }
}

// use private, global scope variable until we can use stored class var in Swift 1.2
private let internalDefaultURLSession = NSURLSession(
    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
    delegate: URLSessionDelegate(),
    delegateQueue: nil
)

public class API {
    // configurations
    public class func baseURL() -> NSURL {
        fatalError("API.baseURL() must be overrided in subclasses.")
    }
    
    public class func requestBodyBuilder() -> RequestBodyBuilder {
        return .JSON(writingOptions: nil)
    }

    public class func responseBodyParser() -> ResponseBodyParser {
        return .JSON(readingOptions: nil)
    }

    public class var defaultURLSession: NSURLSession {
        return internalDefaultURLSession
    }

    public class var acceptableStatusCodes: [Int] {
        return [Int](200..<300)
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

    // In Swift 1.1, we could not omit `URLSession` argument of `func send(request:URLSession(=default):handler(=default):)`
    // with trailing closure, so we provide following 2 methods
    // - `func sendRequest(request:handler(=default):)`
    // - `func sendRequest(request:URLSession:handler(=default):)`.
    // In Swift 1.2, we can omit default arguments with trailing closure, so they should be replaced with
    // - `func sendRequest(request:URLSession(=default):handler(=default):)`
    public class func sendRequest<T: Request>(request: T, handler: (Result<T.Response, NSError>) -> Void = {r in}) -> NSURLSessionDataTask? {
        return sendRequest(request, URLSession: defaultURLSession, handler: handler)
    }

    // send request and build response object
    public class func sendRequest<T: Request>(request: T, URLSession: NSURLSession, handler: (Result<T.Response, NSError>) -> Void = {r in}) -> NSURLSessionDataTask? {
        let mainQueue = dispatch_get_main_queue()
        
        if let URLRequest = request.URLRequest {
            let task = URLSession.dataTaskWithRequest(URLRequest)
            
            task.request = Box(request)
            task.completionHandler = { data, URLResponse, connectionError in
                if let error = connectionError {
                    dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                    return
                }
                
                let statusCode = (URLResponse as? NSHTTPURLResponse)?.statusCode ?? 0
                if !contains(self.acceptableStatusCodes, statusCode) {
                    let error: NSError = {
                        switch self.responseBodyParser().parseData(data) {
                        case .Success(let box): return self.responseErrorFromObject(box.unbox)
                        case .Failure(let box): return box.unbox
                        }
                    }()

                    dispatch_async(mainQueue) { handler(failure(error)) }
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

            return task
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "failed to build request."]
            let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
            dispatch_async(mainQueue, { handler(failure(error)) })

            return nil
        }
    }
    
    public class func cancelRequest<T: Request>(requestType: T.Type, passingTest test: T -> Bool = { r in true }) {
        cancelRequest(requestType, URLSession: defaultURLSession, passingTest: test)
    }
    
    public class func cancelRequest<T: Request>(requestType: T.Type, URLSession: NSURLSession, passingTest test: T -> Bool = { r in true }) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            if let tasks = dataTasks + uploadTasks + downloadTasks as? [NSURLSessionTask] {
                let matchedTasks = tasks.filter { task in
                    if let request = task.request?.unbox as? T {
                        return test(request)
                    } else {
                        return false
                    }
                }
                
                for task in matchedTasks {
                    task.cancel()
                }
            }
        }
    }
    
    public class func responseErrorFromObject(object: AnyObject) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "received status code that represents error"]
        let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
        return error
    }
}

public class URLSessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    // MARK: - NSURLSessionTaskDelegate
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError connectionError: NSError?) {
        if let dataTask = task as? NSURLSessionDataTask {
            dataTask.completionHandler?(dataTask.responseBuffer, dataTask.response, connectionError)
        }
    }

    // MARK: - NSURLSessionDataDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        dataTask.responseBuffer.appendData(data)
    }    
}
