import Foundation

#if APIKIT_DYNAMIC_FRAMEWORK || COCOAPODS
import Result
import Box
#endif

public let APIKitErrorDomain = "APIKitErrorDomain"

public class API {
    // configurations
    public class var baseURL: NSURL {
        fatalError("API.baseURL must be overrided in subclasses.")
    }
    
    public class var requestBodyBuilder: RequestBodyBuilder {
        return .JSON(writingOptions: nil)
    }

    public class var responseBodyParser: ResponseBodyParser {
        return .JSON(readingOptions: nil)
    }

    public class var defaultURLSession: NSURLSession {
        return internalDefaultURLSession
    }

    public class var acceptableStatusCodes: Set<Int> {
        return Set(200..<300)
    }

    private static let internalDefaultURLSession = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: URLSessionDelegate(),
        delegateQueue: nil
    )

    /// Creates a NSURLRequest instance from the specified HTTP method, path string
    /// and parameters dictionary.
    ///
    /// Returns a mutable URL request instance which is meant to be modified in
    /// subclasses or in `Request` protocol conforming types.
    public class func URLRequest(#method: Method, path: String, parameters: [String: AnyObject] = [:], requestBodyBuilder: RequestBodyBuilder = requestBodyBuilder) -> NSMutableURLRequest? {
        if let components = NSURLComponents(URL: baseURL, resolvingAgainstBaseURL: true) {
            let request = NSMutableURLRequest()
            
            switch method {
            case .GET, .HEAD, .DELETE:
                components.query = URLEncodedSerialization.stringFromObject(parameters, encoding: NSUTF8StringEncoding)
                
            default:
                switch requestBodyBuilder.buildBodyFromObject(parameters) {
                case .Success(let box):
                    request.HTTPBody = box.value
                    
                case .Failure(let box):
                    return nil
                }
            }
            
            components.path = (components.path ?? "").stringByAppendingPathComponent(path)
            request.URL = components.URL
            request.HTTPMethod = method.rawValue
            request.setValue(requestBodyBuilder.contentTypeHeader, forHTTPHeaderField: "Content-Type")
            request.setValue(responseBodyParser.acceptHeader, forHTTPHeaderField: "Accept")
            
            return request
        } else {
            return nil
        }
    }
    
    @availability(*, unavailable, renamed="URLRequest(method:path:parameters:requestBodyBuilder)")
    public class func URLRequest(method: Method, _ path: String, _ parameters: [String: AnyObject] = [:], requestBodyBuilder: RequestBodyBuilder = requestBodyBuilder) -> NSURLRequest? {
        return URLRequest(method: method, path: path, parameters: parameters, requestBodyBuilder: requestBodyBuilder)
    }

    // send request and build response object
    public class func sendRequest<T: Request>(request: T, URLSession: NSURLSession = defaultURLSession, handler: (Result<T.Response, NSError>) -> Void = {r in}) -> NSURLSessionDataTask? {
        let mainQueue = dispatch_get_main_queue()
        
        if let URLRequest = request.URLRequest {
            let task = URLSession.dataTaskWithRequest(URLRequest)
            
            task.request = Box(request)
            task.completionHandler = { data, URLResponse, connectionError in
                if let error = connectionError {
                    dispatch_async(mainQueue) { handler(.failure(error)) }
                    return
                }
                
                let statusCode = (URLResponse as? NSHTTPURLResponse)?.statusCode ?? 0
                if !contains(self.acceptableStatusCodes, statusCode) {
                    let error = self.responseBodyParser.parseData(data).analysis(
                        ifSuccess: { self.responseErrorFromObject($0) },
                        ifFailure: { $0 }
                    )

                    dispatch_async(mainQueue) { handler(.failure(error)) }
                    return
                }
                
                let mappedResponse: Result<T.Response, NSError> = self.responseBodyParser.parseData(data).flatMap { rawResponse in
                    if let response = T.responseFromObject(rawResponse) {
                        return .success(response)
                    } else {
                        let userInfo = [NSLocalizedDescriptionKey: "failed to create model object from raw object."]
                        let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
                        return .failure(error)
                    }
                }
                
                dispatch_async(mainQueue) { handler(mappedResponse) }
            }
            
            task.resume()

            return task
        } else {
            let userInfo = [NSLocalizedDescriptionKey: "failed to build request."]
            let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
            dispatch_async(mainQueue) { handler(.failure(error)) }

            return nil
        }
    }
    
    public static func cancelRequest<T: Request>(requestType: T.Type, passingTest test: T -> Bool = { r in true }) {
        cancelRequest(requestType, URLSession: defaultURLSession, passingTest: test)
    }
    
    public static func cancelRequest<T: Request>(requestType: T.Type, URLSession: NSURLSession, passingTest test: T -> Bool = { r in true }) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let tasks = (dataTasks + uploadTasks + downloadTasks).filter { task in
                var request: T?
                switch task {
                case let x as NSURLSessionDataTask:
                    request = x.request?.value as? T
                    
                case let x as NSURLSessionDownloadTask:
                    request = x.request?.value as? T
                    
                default:
                    break
                }
                
                if let request = request {
                    return test(request)
                } else {
                    return false
                }
            }
            
            for task in tasks {
                task.cancel()
            }
        }
    }
    
    public class func responseErrorFromObject(object: AnyObject) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: "received status code that represents error"]
        let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
        return error
    }
}

// MARK: - default implementation of URLSessionDelegate
public class URLSessionDelegate: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    // MARK: NSURLSessionTaskDelegate
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError connectionError: NSError?) {
        if let dataTask = task as? NSURLSessionDataTask {
            dataTask.completionHandler?(dataTask.responseBuffer, dataTask.response, connectionError)
        }
    }

    // MARK: NSURLSessionDataDelegate
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        dataTask.responseBuffer.appendData(data)
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didBecomeDownloadTask downloadTask: NSURLSessionDownloadTask) {
        downloadTask.request = dataTask.request
    }
}

// MARK: - NSURLSessionTask extensions
private var taskRequestKey = 0
private var dataTaskResponseBufferKey = 0
private var dataTaskCompletionHandlerKey = 0

private extension NSURLSessionDataTask {
    // `var request: Request?` is not available in Swift 1.2
    // ("protocol can only be used as a generic constraint")
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
            return (objc_getAssociatedObject(self, &dataTaskCompletionHandlerKey) as? Box<(NSData, NSURLResponse?, NSError?) -> Void>)?.value
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

extension NSURLSessionDownloadTask {
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
