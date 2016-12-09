import Foundation

/// `CallbackQueue` represents queue where `handler` of `Session.send(_:handler:)` runs.
public enum CallbackQueue {
    /// Dispatches callback closure on main queue asynchronously.
    case main

    /// Dispatches callback closure on the queue where backend adapter callback runs.
    case sessionQueue

    /// Dispatches callback closure on associated operation queue.
    case operationQueue(OperationQueue)

    /// Dispatches callback closure on associated dispatch queue.
    case dispatchQueue(DispatchQueue)

    public func execute(closure: @escaping () -> Void) {
        switch self {
        case .main:
            DispatchQueue.main.async {
                closure()
            }

        case .sessionQueue:
            closure()

        case .operationQueue(let operationQueue):
            operationQueue.addOperation {
                closure()
            }

        case .dispatchQueue(let dispatchQueue):
            dispatchQueue.async {
                closure()
            }
        }
    }
}
