#if canImport(Combine)

import Foundation
import Combine

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public struct RequestPublisher<Request: APIKit.Request>: Publisher {
    public typealias Output = Request.Response
    public typealias Failure = SessionTaskError

    private let session: Session
    private let request: Request
    private let callbackQueue: CallbackQueue?

    public init(session: Session, request: Request, callbackQueue: CallbackQueue?) {
        self.session = session
        self.request = request
        self.callbackQueue = callbackQueue
    }

    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        subscriber.receive(subscription: RequestSubscription(session: session,
                                                             request: request,
                                                             callbackQueue: callbackQueue,
                                                             downstream: subscriber))
    }

    private final class RequestSubscription<Request: APIKit.Request, Downstream: Subscriber>: Subscription where Downstream.Input == Request.Response, Downstream.Failure == Failure {

        private let session: Session
        private let request: Request
        private let callbackQueue: CallbackQueue?
        private var downstream: Downstream?
        private var task: SessionTask?

        init(session: Session, request: Request, callbackQueue: CallbackQueue?, downstream: Downstream) {
            self.session = session
            self.request = request
            self.callbackQueue = callbackQueue
            self.downstream = downstream
        }

        func request(_ demand: Subscribers.Demand) {
            assert(demand > 0)
            guard let downstream = self.downstream else { return }
            self.downstream = nil
            task = session.send(request, callbackQueue: callbackQueue) { result in
                switch result {
                case .success(let response):
                    _ = downstream.receive(response)
                    downstream.receive(completion: .finished)
                case .failure(let error):
                    downstream.receive(completion: .failure(error))
                }
            }
        }

        func cancel() {
            task?.cancel()
            downstream = nil
        }
    }
}

@available(macOS 10.15, iOS 13, watchOS 6, tvOS 13, *)
public extension Session {
    /// Calls `publisher(_:callbackQueue:)` of `shared`.
    /// - parameter request: The request to be sent.
    /// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
    /// - returns: The new request publisher.
    static func publisher<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil) -> RequestPublisher<Request> {
        return RequestPublisher(session: .shared, request: request, callbackQueue: callbackQueue)
    }

    /// Returns a publisher that wraps a task for a given `Request`.
    ///
    /// The publisher publishes `Request.Response` when the task completes, or terminates if the task fails with an error.
    /// - parameter request: The request to be sent.
    /// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
    /// - returns: The new request publisher.
    func publisher<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil) -> RequestPublisher<Request> {
        return RequestPublisher(session: self, request: request, callbackQueue: callbackQueue)
    }
}

#endif
