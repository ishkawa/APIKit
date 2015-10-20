import Foundation
import Result

public protocol RequestInterceptorType {
    func interceptBeforeRequest<T: RequestType>(request: T)
    func interceptAfterRequest<T: RequestType>(request: T, result: Result<T.Response, APIError>)
}
