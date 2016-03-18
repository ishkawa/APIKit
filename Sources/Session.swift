import Foundation
import Result

private var taskRequestKey = 0

public class Session {
    public let adapter: SessionAdapterType

    public init(adapter: SessionAdapterType) {
        self.adapter = adapter
    }

    // Shared session for static methods
    public static var sharedSession: Session = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let adapter = NSURLSessionAdapter(configuration: configuration)
        return Session(adapter: adapter)
    }()

    public static func sendRequest<T: RequestType>(request: T, handler: (Result<T.Response, SessionTaskError>) -> Void = {r in}) -> SessionTaskType? {
        return sharedSession.sendRequest(request, handler: handler)
    }
    
    public static func cancelRequest<T: RequestType>(requestType: T.Type, passingTest test: T -> Bool = { r in true }) {
        sharedSession.cancelRequest(requestType, passingTest: test)
    }

    public func sendRequest<T: RequestType>(request: T, handler: (Result<T.Response, SessionTaskError>) -> Void = {r in}) -> SessionTaskType? {
        let URLRequest: NSURLRequest
        do {
            URLRequest = try request.buildURLRequest()
        } catch {
            dispatch_async(dispatch_get_main_queue()) {
                handler(.Failure(.RequestError(error)))
            }
            return nil
        }

        let task = adapter.resumedTaskWithURLRequest(URLRequest) { data, URLResponse, error in
            let result: Result<T.Response, SessionTaskError>

            switch (data, URLResponse, error) {
            case (_, _, let error?):
                result = .Failure(.ConnectionError(error))

            case (let data?, let URLResponse as NSHTTPURLResponse, _):
                do {
                    result = .Success(try request.parseData(data, URLResponse: URLResponse))
                } catch {
                    result = .Failure(.ResponseError(error))
                }

            default:
                result = .Failure(.ResponseError(ResponseError.NonHTTPResponse(URLResponse)))
            }

            dispatch_async(dispatch_get_main_queue()) {
                handler(result)
            }
        }

        setRequest(request, forTask: task)

        return task
    }

    public func cancelRequest<T: RequestType>(requestType: T.Type, passingTest test: T -> Bool = { r in true }) {
        adapter.getTasksWithHandler { [weak self] tasks in
            tasks
                .filter { task in
                    if let request = self?.requestForTask(task) as T? {
                        return test(request)
                    } else {
                        return false
                    }
                }
                .forEach { $0.cancel() }
        }
    }

    private func setRequest<T: RequestType>(request: T, forTask task: SessionTaskType) {
        objc_setAssociatedObject(task, &taskRequestKey, Box(request), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    private func requestForTask<T: RequestType>(task: SessionTaskType) -> T? {
        return (objc_getAssociatedObject(task, &taskRequestKey) as? Box<T>)?.value
    }
}
