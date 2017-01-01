import PlaygroundSupport
import Foundation
import APIKit

PlaygroundPage.current.needsIndefiniteExecution = true

//: Step 1: Define request protocol
protocol GitHubRequest: Request {

}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }
}

//: Step 2: Create model object
struct RateLimit {
    let count: Int
    let resetDate: Date

    init?(jsonObject: [String: Any]) {
        guard let count = jsonObject["limit"] as? Int else {
            return nil
        }

        guard let resetDateString = jsonObject["reset"] as? TimeInterval else {
            return nil
        }

        self.count = count
        self.resetDate = Date(timeIntervalSince1970: resetDateString)
    }
}

//: Step 3: Define request type conforming to created request protocol
// https://developer.github.com/v3/rate_limit/
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit

    var method: HTTPMethod {
        return .get
    }

    var path: String {
        return "/rate_limit"
    }

    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        guard
            let rootObject = object as? [String: Any],
            let rateObject = rootObject["rate"] as? [String: Any],
            let rateLimit = RateLimit(jsonObject: rateObject) else {
            throw ResponseError.unexpectedObject(object)
        }

        return rateLimit
    }
}

//: Step 4: Send request
let request = GetRateLimitRequest()

Session.send(request) { result in
    switch result {
    case .success(let rateLimit):
        print("count: \(rateLimit.count)")
        print("reset: \(rateLimit.resetDate)")

    case .failure(let error):
        print("error: \(error)")
    }
}
