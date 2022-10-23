import PlaygroundSupport
import Foundation
import APIKit

PlaygroundPage.current.needsIndefiniteExecution = true

//: Step 1: Define request protocol
protocol GitHubRequest: Request {}

extension GitHubRequest {
    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var dataParser: NonSerializedJSONDataParser {
        return NonSerializedJSONDataParser()
    }
}

//: Step 2: Create model object
struct RateLimit: Decodable {
    let count: Int
    let resetDate: Date

    enum CodingKeys: String, CodingKey {
        case rate
    }
    enum RateCodingKeys: String, CodingKey {
        case limit
        case reset
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let rateContainer = try container.nestedContainer(keyedBy: RateCodingKeys.self, forKey: .rate)
        self.count = try rateContainer.decode(Int.self, forKey: .limit)
        let resetTimeInterval = try rateContainer.decode(TimeInterval.self, forKey: .reset)
        self.resetDate = Date(timeIntervalSince1970: resetTimeInterval)
    }
}

//: Step 3: Define request type conforming to created request protocol
// https://developer.github.com/v3/rate_limit/
struct GetRateLimitRequest: GitHubRequest {
    typealias Response = RateLimit

    let method: HTTPMethod = .get
    let path: String = "/rate_limit"

    func response(from object: Data, urlResponse: HTTPURLResponse) throws -> Response {
        return try JSONDecoder().decode(Response.self, from: object)
    }
}

//: Step 4: Send request
let request = GetRateLimitRequest()

Session.send(request, uploadProgressHandler: { progress in
    print("upload progress: \(progress.fractionCompleted)")
}, downloadProgressHandler: { progress in
    print("download progress: \(progress.fractionCompleted) %")
}, completionHandler: { result in
    switch result {
    case .success(let rateLimit):
        print("count: \(rateLimit.count)")
        print("reset: \(rateLimit.resetDate)")
    case .failure(let error):
        print("error: \(error)")
    }
})
