import Foundation
import Result

public enum RequestPhase<T: RequestType> {
    case NotStarted
    case InProgress
    case Finished(Result<T.Response, APIError>)
}
