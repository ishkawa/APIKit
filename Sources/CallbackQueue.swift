import Foundation

/// `CallbackQueue` represents queue where `handler` of `Session.sendRequest(_:handler:)` runs.
public enum CallbackQueue {
    /// Dispatches callback closure on main queue asynchronously.
    case Main

    /// Dispatches callback closure on the queue where backend adapter callback runs.
    case SessionQueue

    /// Dispatches callback closure on associated operation queue.
    case OperationQueue(NSOperationQueue)

    /// Dispatches callback closure on associated dispatch queue.
    case DispatchQueue(dispatch_queue_t)

    internal func execute(closure: () -> Void) {
        switch self {
        case .Main:
            dispatch_async(dispatch_get_main_queue()) {
                closure()
            }

        case .SessionQueue:
            closure()

        case .OperationQueue(let operationQueue):
            operationQueue.addOperationWithBlock {
                closure()
            }

        case .DispatchQueue(let dispatchQueue):
            dispatch_async(dispatchQueue) {
                closure()
            }
        }
    }
}
