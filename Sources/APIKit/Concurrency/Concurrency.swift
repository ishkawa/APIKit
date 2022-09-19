#if compiler(>=5.5.2) && canImport(_Concurrency)

import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Session {
    static func response<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) async throws -> Request.Response {
        return try await shared.response(for: request, callbackQueue: callbackQueue)
    }

    func response<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) async throws -> Request.Response {
        let cancellationHandler = SessionTaskCancellationHandler()
        return try await withTaskCancellationHandler(operation: {
            return try await withUnsafeThrowingContinuation { continuation in
                Task {
                    let sessionTask = send(request, callbackQueue: callbackQueue) { result in
                        switch result {
                        case .success(let response):
                            continuation.resume(returning: response)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                    await cancellationHandler.register(with: sessionTask)
                }
            }
        }, onCancel: {
            Task { await cancellationHandler.cancel() }
        })
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private actor SessionTaskCancellationHandler {
    private var sessionTask: SessionTask?
    
    func register(with task: SessionTask?) {
        guard sessionTask == nil else { return }
        sessionTask = task
    }

    func cancel() {
        sessionTask?.cancel()
        sessionTask = nil
    }
}

#endif
