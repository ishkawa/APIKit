import Result

public protocol RequestObserverType {
    func handleBeforeRequest<T: RequestType>(request: T)
    func handleAfterRequest<T: RequestType>(request: T, result: Result<T.Response, APIError>)
}
