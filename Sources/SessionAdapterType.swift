import Foundation

public protocol SessionTaskType: class {
    func cancel()
}

public protocol SessionAdapterType {
    func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType
    func getTasksWithHandler(handler: [SessionTaskType] -> Void)
}
