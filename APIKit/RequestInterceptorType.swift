import Foundation

public protocol RequestInterceptorType {
    func interceptRequest<T: RequestType>(request: T, phase: RequestPhase<T>)
}
