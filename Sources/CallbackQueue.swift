import Foundation

/// `CallbackQueue` represents queue where `handler` of `Session.sendRequest(_:handler:)` runs.
public enum CallbackQueue {
    /// Dispatches callback closure on main queue asynchronously.
    case Main

    /// Dispatches callback closure on the queue where backend adapter callback runs.
    case SessionQueue

    /// Dispatches callback closure on associated operation queue.
    case OperationQueue(OperationQueue)

    /// Dispatches callback closure on associated dispatch queue.
    case DispatchQueue(Foundation.DispatchQueue)

    internal func execute(closure: () -> Void) {
        switch self {
        case .Main:
            Foundation.DispatchQueue.main.async {
                closure()
            }

        case .SessionQueue:
            closure()

        case .OperationQueue(let operationQueue):
            operationQueue.addOperation {
                closure()
            }

        case .DispatchQueue(let dispatchQueue):
            dispatchQueue.async {
                closure()
            }
        }
    }
}
