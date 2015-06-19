import XCPlayground
import UIKit
import APIKit

XCPSetExecutionShouldContinueIndefinitely()

/// Sending request
let request = GitHubAPI.GetRateLimit()

GitHubAPI.sendRequest(request) { result in
    switch result {
    case .Success(let rateLimit):
        print("remaining count: \(rateLimit.count)")
        print("reset date: \(rateLimit.resetDate)")

    case .Failure(let error):
        print("error: \(error)")
    }
}

/// Defining request protocol
protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

/// Defining API class
class GitHubAPI: API {
    enum Errors: ErrorType {
        case Some
    }

    // https://developer.github.com/v3/rate_limit/
    struct GetRateLimit: GitHubRequest {
        typealias Response = RateLimit

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/rate_limit"
        }

        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response {
            guard let dictionary = object as? [String: AnyObject] else {
                throw Errors.Some
            }

            guard let rateLimit = RateLimit(dictionary: dictionary) else {
                throw Errors.Some
            }

            return rateLimit
        }
    }
}

/// Model object
struct RateLimit {
    let count: Int
    let resetDate: NSDate

    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }

        guard let resetDateString = dictionary["rate"]?["reset"] as? NSTimeInterval else {
            return nil
        }

        self.count = count
        self.resetDate = NSDate(timeIntervalSince1970: resetDateString)
    }
}

