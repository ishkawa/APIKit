import Foundation

public enum CallbackQueue {
    case Main
    case SessionQueue
    case OperationQueue(NSOperationQueue)
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
