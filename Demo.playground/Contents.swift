import PlaygroundSupport
import UIKit
import APIKit

PlaygroundPage.current.needsIndefiniteExecution = true

//: Step 1: Define request protocol
protocol GitHubRequestType: RequestType {

}

extension GitHubRequestType {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

//: Step 2: Create model object
struct RateLimit {
    let count: Int
    let resetDate: Date

    init?(dictionary: [String: AnyObject]) {
        guard let count = dictionary["rate"]?["limit"] as? Int else {
            return nil
        }

        guard let resetDateString = dictionary["rate"]?["reset"] as? TimeInterval else {
            return nil
        }

        self.count = count
        self.resetDate = Date(timeIntervalSince1970: resetDateString)
    }
}

//: Step 3: Define request type conforming to created request protocol
// https://developer.github.com/v3/rate_limit/
struct GetRateLimitRequest: GitHubRequestType {
    typealias Response = RateLimit

    var method: HTTPMethod {
        return .GET
    }

    var path: String {
        return "/rate_limit"
    }

    func responseFromObject(_ object: AnyObject, urlResponse: HTTPURLResponse) throws -> Response {
        guard let dictionary = object as? [String: AnyObject],
              let rateLimit = RateLimit(dictionary: dictionary) else {
            throw ResponseError.UnexpectedObject(object)
        }

        return rateLimit
    }
}

//: Step 4: Send request
let request = GetRateLimitRequest()

Session.sendRequest(request) { result in
    switch result {
    case .success(let rateLimit):
        print("count: \(rateLimit.count)")
        print("reset: \(rateLimit.resetDate)")

    case .failure(let error):
        print("error: \(error)")
    }
}
