#if canImport(Combine)

import Foundation
import Combine

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public struct SessionTaskPublisher<Request: APIKit.Request>: Publisher {
    /// The kind of values published by this publisher.
    public typealias Output = Request.Response

    /// The kind of errors this publisher might publish.
    public typealias Failure = SessionTaskError

    private let request: Request
    private let session: Session
    private let callbackQueue: CallbackQueue?

    public init(request: Request, session: Session, callbackQueue: CallbackQueue?) {
        self.request = request
        self.session = session
        self.callbackQueue = callbackQueue
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == SessionTaskPublisher.Failure, S.Input == SessionTaskPublisher.Output {
        subscriber.receive(subscription: SessionTaskSubscription(request: request,
                                                                 session: session,
                                                                 callbackQueue: callbackQueue,
                                                                 downstream: subscriber))
    }

    private final class SessionTaskSubscription<Request: APIKit.Request, Downstream: Subscriber>: Subscription where Request.Response == Downstream.Input, Downstream.Failure == Failure {

        private let request: Request
        private let session: Session
        private let callbackQueue: CallbackQueue?
        private var downstream: Downstream?
        private var task: SessionTask?

        init(request: Request, session: Session, callbackQueue: CallbackQueue?, downstream: Downstream) {
            self.request = request
            self.session = session
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

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension Session {
    /// Calls `sessionTaskPublisher(for:callbackQueue:)` of `Session.shared`.
    /// 
    /// - parameter request: The request to be sent.
    /// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
    /// - returns: A publisher that wraps a session task for the request.
    static func sessionTaskPublisher<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) -> SessionTaskPublisher<Request> {
        return SessionTaskPublisher(request: request, session: .shared, callbackQueue: callbackQueue)
    }

    /// Returns a publisher that wraps a session task for the request.
    ///
    /// The publisher publishes `Request.Response` when the task completes, or terminates if the task fails with an error.
    /// - parameter request: The request to be sent.
    /// - parameter callbackQueue: The queue where the handler runs. If this parameters is `nil`, default `callbackQueue` of `Session` will be used.
    /// - returns: A publisher that wraps a session task for the request.
    func sessionTaskPublisher<Request: APIKit.Request>(for request: Request, callbackQueue: CallbackQueue? = nil) -> SessionTaskPublisher<Request> {
        return SessionTaskPublisher(request: request, session: self, callbackQueue: callbackQueue)
    }
}

#endif
