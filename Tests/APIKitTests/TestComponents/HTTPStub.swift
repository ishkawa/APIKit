import Foundation
import Dispatch
import Result

class HTTPStub: URLProtocol {
    static var stubResult: Result<Data, NSError> = .success(Data())

    private var isCancelled = false

    // MARK: URLProtocol -
    
    override class func canInit(with: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: "1.1",
            headerFields: nil)

        let queue = DispatchQueue.global(qos: .default)

        queue.asyncAfter(deadline: .now() + 0.01) {
            guard !self.isCancelled else {
                return
            }
            
            self.client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)

            switch HTTPStub.stubResult {
            case .success(let data):
                self.client?.urlProtocol(self, didLoad: data)

            case .failure(let error):
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {
        isCancelled = true
    }
}
