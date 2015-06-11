import Foundation
import Result

public let APIKitErrorDomain = "APIKitErrorDomain"

public class API {
    public class var defaultURLSession: NSURLSession {
        return internalDefaultURLSession
    }

    private static let internalDefaultURLSession = NSURLSession(
        configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
        delegate: URLSessionDelegate(),
        delegateQueue: nil
    )

    // send request and build response object
    public class func sendRequest<T: Request>(request: T, URLSession: NSURLSession = defaultURLSession, handler: (Result<T.Response, NSError>) -> Void = {r in}) -> NSURLSessionDataTask? {
        let mainQueue = dispatch_get_main_queue()
        let URLRequest: NSURLRequest
        do {
            URLRequest = try request.buildURLRequest()
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "failed to build request."]
            let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
            dispatch_async(mainQueue) { handler(.failure(error)) }
            return nil
        }

        guard let task = URLSession.dataTaskWithRequest(URLRequest) else {
            // TODO: throw error
            abort()
        }

        task.request = Box(request)
        task.completionHandler = { data, URLResponse, connectionError in
            if let error = connectionError {
                dispatch_async(mainQueue) { handler(.failure(error)) }
                return
            }

            guard let HTTPURLResponse = URLResponse as? NSHTTPURLResponse else {
                let userInfo = [NSLocalizedDescriptionKey: "failed to get NSHTTPURLResponse."]
                let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
                dispatch_async(mainQueue) { handler(.failure(error)) }
                return
            }

            if !request.acceptableStatusCodes.contains(HTTPURLResponse.statusCode) {
                let error = request.responseBodyParser.parseData(data).analysis(
                    ifSuccess: { request.buildErrorFromObject($0, URLResponse: HTTPURLResponse) },
                    ifFailure: { $0 }
                )
                dispatch_async(mainQueue) { handler(.failure(error)) }
                return
            }

            let mappedResponse: Result<T.Response, NSError> = request.responseBodyParser.parseData(data).flatMap { rawResponse in
                do {
                    return .success(try request.buildResponseFromObject(rawResponse, URLResponse: HTTPURLResponse))
                } catch {
                    let userInfo = [NSLocalizedDescriptionKey: "failed to create model object from raw object."]
                    let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
                    return .failure(error)
                }
            }

            dispatch_async(mainQueue) { handler(mappedResponse) }
        }

        task.resume()

        return task
    }

    public class func cancelRequest<T: Request>(requestType: T.Type, passingTest test: T -> Bool = { r in true }) {
        cancelRequest(requestType, URLSession: defaultURLSession, passingTest: test)
    }
    
    public class func cancelRequest<T: Request>(requestType: T.Type, URLSession: NSURLSession, passingTest test: T -> Bool = { r in true }) {
        URLSession.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            // TODO: replace with cool code
            var allTasks = [NSURLSessionTask]()
            for task in dataTasks {
                allTasks.append(task)
            }
            for task in uploadTasks {
                allTasks.append(task)
            }
            for task in downloadTasks {
                allTasks.append(task)
            }

            let tasks = allTasks.filter { task in
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

// Box<T> is still necessary internally to store struct into associated object
private final class Box<T> {
    let value: T
    init(_ value: T) {
        self.value = value
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
                objc_setAssociatedObject(self, &taskRequestKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &taskRequestKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    private var responseBuffer: NSMutableData {
        if let responseBuffer = objc_getAssociatedObject(self, &dataTaskResponseBufferKey) as? NSMutableData {
            return responseBuffer
        } else {
            let responseBuffer = NSMutableData()
            objc_setAssociatedObject(self, &dataTaskResponseBufferKey, responseBuffer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return responseBuffer
        }
    }
    
    private var completionHandler: ((NSData, NSURLResponse?, NSError?) -> Void)? {
        get {
            return (objc_getAssociatedObject(self, &dataTaskCompletionHandlerKey) as? Box<(NSData, NSURLResponse?, NSError?) -> Void>)?.value
        }
        
        set {
            if let value = newValue  {
                objc_setAssociatedObject(self, &dataTaskCompletionHandlerKey, Box(value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &dataTaskCompletionHandlerKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
                objc_setAssociatedObject(self, &taskRequestKey, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                objc_setAssociatedObject(self, &taskRequestKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
