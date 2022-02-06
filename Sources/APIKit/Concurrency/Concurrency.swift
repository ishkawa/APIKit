#if compiler(>=5.5.2) && canImport(_Concurrency)

import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private actor SessionTaskActor {
    private weak var sessionTask: SessionTask?

    func send(_ sessionTask: SessionTask?) {
        self.sessionTask = sessionTask
    }

    func cancel() {
        sessionTask?.cancel()
    }
}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Session {
    static func response<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) async throws -> Request.Response {
        return try await shared.response(for: request, callbackQueue: callbackQueue)
    }

    func response<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) async throws -> Request.Response {
        let sessionTaskActor = SessionTaskActor()
        return try await withTaskCancellationHandler(operation: {
            return try await withUnsafeThrowingContinuation { continuation in
                Task {
                    await sessionTaskActor.send(send(request, callbackQueue: callbackQueue) { result in
                        switch result {
                        case .success(let response):
                            continuation.resume(returning: response)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    })
                }
            }
        }, onCancel: {
            Task { await sessionTaskActor.cancel() }
        })
    }
}

#endif
