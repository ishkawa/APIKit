import XCPlayground
import UIKit
import APIKit

XCPSetExecutionShouldContinueIndefinitely()

//: Step 1: Define request protocol
protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
}

//: Step 2: Create API class
class GitHubAPI: API {
    
}

//: Step 3: Create model object
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

//: Step 4: Define requet type in API class
extension GitHubAPI {
    // https://developer.github.com/v3/rate_limit/
    struct GetRateLimit: GitHubRequest {
        typealias Response = RateLimit

        var method: HTTPMethod {
            return .GET
        }

        var path: String {
            return "/rate_limit"
        }

        func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response? {
            guard let dictionary = object as? [String: AnyObject] else {
                return nil
            }

            guard let rateLimit = RateLimit(dictionary: dictionary) else {
                return nil
            }

            return rateLimit
        }
    }
}

//: Step 5: Send request
let request = GitHubAPI.GetRateLimit()

GitHubAPI.sendRequest(request) { result in
    switch result {
    case .Success(let rateLimit):
        "count: \(rateLimit.count)"
        "reset: \(rateLimit.resetDate)"

    case .Failure(let error):
        "error: \(error)"
    }
}

