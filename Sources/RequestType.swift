import Foundation
import Result

/// `RequestType` protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - `typealias Response`
/// - `var baseURL: URL`
/// - `var method: HTTPMethod`
/// - `var path: String`
/// - `func responseFromObject(object: AnyObject, urlResponse: HTTPURLResponse) throws -> Response`
public protocol RequestType {
    /// The response type associated with the request type.
    associatedtype Response

    /// The base URL.
    var baseURL: URL { get }

    /// The HTTP request method.
    var method: HTTPMethod { get }

    /// The path URL component.
    var path: String { get }

    /// The convenience property for `queryParameters` and `bodyParameters`. If the implementation of
    /// `queryParameters` and `bodyParameters` are not provided, the values for them will be computed
    /// from this property depending on `method`.
    var parameters: AnyObject? { get }

    /// The actual parameters for the URL query. The values of this property will be escaped using `URLEncodedSerialization`.
    /// If this property is not implemented and `method.prefersQueryParameter` is `true`, the value of this property
    /// will be computed from `parameters`.
    var queryParameters: [String: AnyObject]? { get }

    /// The actual parameters for the HTTP body. If this property is not implemented and `method.prefersQueryParameter` is `false`,
    /// the value of this property will be computed from `parameters` using `JSONBodyParameters`.
    var bodyParameters: BodyParametersType? { get }

    /// The HTTP header fields. In addition to fields defined in this property, `Accept` and `Content-Type`
    /// fields will be added by `dataParser` and `bodyParameters`. If you define `Accept` and `Content-Type`
    /// in this property, the values in this property are preferred.
    var headerFields: [String: String] { get }

    /// The parser object that states `Content-Type` to accept and parses response body.
    var dataParser: DataParserType { get }

    /// Intercepts `URLRequest` which is created by `RequestType.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `Session.sendRequest()` turns `.Failure(.RequestError(error))`.
    /// - Throws: `ErrorType`
    func interceptURLRequest(_ urlRequest: URLRequest) throws -> URLRequest

    /// Intercepts response `AnyObject` and `HTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.sendRequest()` turns `.Failure(.ResponseError(error))`.
    /// The default implementation of this method is provided to throw `RequestError.UnacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    /// - Throws: `ErrorType`
    func interceptObject(_ object: AnyObject, urlResponse: HTTPURLResponse) throws -> AnyObject

    /// Build `Response` instance from raw response object. This method is called after
    /// `interceptObject(:URLResponse:)` if it does not throw any error.
    /// - Throws: `ErrorType`
    func responseFromObject(_ object: AnyObject, urlResponse: HTTPURLResponse) throws -> Response
}

public extension RequestType {
    public var parameters: AnyObject? {
        return nil
    }

    public var queryParameters: [String: AnyObject]? {
        guard let parameters = parameters as? [String: AnyObject], method.prefersQueryParameters else {
            return nil
        }

        return parameters
    }

    public var bodyParameters: BodyParametersType? {
        guard let parameters = parameters, !method.prefersQueryParameters else {
            return nil
        }

        return JSONBodyParameters(JSONObject: parameters)
    }

    public var headerFields: [String: String] {
        return [:]
    }

    public var dataParser: DataParserType {
        return JSONDataParser(readingOptions: [])
    }

    public func interceptURLRequest(_ urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    public func interceptObject(_ object: AnyObject, urlResponse: HTTPURLResponse) throws -> AnyObject {
        guard (200..<300).contains(urlResponse.statusCode) else {
            throw ResponseError.UnacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }

    /// Builds `URLRequest` from properties of `self`.
    /// - Throws: `RequestError`, `ErrorType`
    public func buildURLRequest() throws -> URLRequest {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.InvalidBaseURL(baseURL)
        }

        var urlRequest = URLRequest(url: url)

        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.percentEncodedQuery = URLEncodedSerialization.stringFromDictionary(queryParameters)
        }

        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")

            switch try bodyParameters.buildEntity() {
            case .Data(let data):
                urlRequest.httpBody = data

            case .InputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }

        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")

        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return (try interceptURLRequest(urlRequest) as URLRequest)
    }

    /// Builds `Response` from response `Data`.
    /// - Throws: `ResponseError`, `ErrorType`
    public func parseData(_ data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        let parsedObject = try dataParser.parseData(data)
        let passedObject = try interceptObject(parsedObject, urlResponse: urlResponse)
        return try responseFromObject(passedObject, urlResponse: urlResponse)
    }
}
