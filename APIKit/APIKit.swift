import Foundation
import LlamaKit

public let APIKitErrorDomain = "APIKitErrorDomain"

public protocol Request {
    typealias Response: Any
    
    var URLRequest: NSURLRequest { get }
    
    func responseFromObject(object: AnyObject) -> Response?
}

public class API {
    // configurations
    public class func URLSession() -> NSURLSession {
        return NSURLSession.sharedSession()
    }

    public class func responseBodyEncoding() -> ResponseBodyEncoding {
        return .JSON(nil)
    }

    public enum ResponseBodyEncoding {
        case JSON(NSJSONReadingOptions)
        case URL(NSStringEncoding)
        case Custom(NSData -> Result<AnyObject, NSError>)

        public func decode(data: NSData) -> Result<AnyObject, NSError> {
            var result: Result<AnyObject, NSError>

            switch self {
            case .JSON(let readingOptions):
                var error: NSError?
                if let object: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: readingOptions, error: &error) {
                    result = Result.Success(Box(object))
                } else {
                    // According to doc of NSJSONSerialization, error must occur if return value is nil.
                    result = Result.Failure(Box(error!))
                }

            case .URL(let encoding):
                var dictionary = [String: AnyObject]()

                if let string = NSString(data: data, encoding: encoding) as? String {
                    let URLComponents = NSURLComponents()
                    URLComponents.query = string

                    if let queryItems = URLComponents.queryItems as? [NSURLQueryItem] {
                        for queryItem in queryItems {
                            dictionary[queryItem.name] = queryItem.value
                        }
                    }
                }

                result = Result.Success(Box(dictionary))

            case .Custom(let decode):
                result = decode(data)
            }

            return result
        }
    }

    public class func sendRequest<T: Request>(request: T, handler: (Result<T.Response, NSError>) -> Void = {r in}) {
        let session = URLSession()
        let task = session.dataTaskWithRequest(request.URLRequest) { data, URLResponse, connectionError in
            let mainQueue = dispatch_get_main_queue()
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

            switch self.responseBodyEncoding().decode(data) {
            case .Failure(let box):
                dispatch_async(mainQueue, { handler(.Failure(Box(box.unbox))) })

            case .Success(let box):
                if let response = request.responseFromObject(box.unbox) {
                    dispatch_async(mainQueue, { handler(.Success(Box(response))) })
                } else {
                    let userInfo = [NSLocalizedDescriptionKey: "failed to create model object from raw object."]
                    let error = NSError(domain: APIKitErrorDomain, code: 0, userInfo: userInfo)
                    dispatch_async(mainQueue, { handler(.Failure(Box(error))) })
                }
            }
        }
        
        task.resume()
    }
}
