import Foundation

/// `Request` protocol represents a request for Web API.
/// Following 5 items must be implemented.
/// - `typealias Response`
/// - `var baseURL: URL`
/// - `var method: HTTPMethod`
/// - `var path: String`
/// - `func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response`
public protocol Request {
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
    var parameters: Any? { get }

    /// The actual parameters for the URL query. The values of this property will be escaped using `URLEncodedSerialization`.
    /// If this property is not implemented and `method.prefersQueryParameter` is `true`, the value of this property
    /// will be computed from `parameters`.
    var queryParameters: QueryParameters? { get }

    /// The actual parameters for the HTTP body. If this property is not implemented and `method.prefersQueryParameter` is `false`,
    /// the value of this property will be computed from `parameters` using `JSONBodyParameters`.
    var bodyParameters: BodyParameters? { get }

    /// The HTTP header fields. In addition to fields defined in this property, `Accept` and `Content-Type`
    /// fields will be added by `dataParser` and `bodyParameters`. If you define `Accept` and `Content-Type`
    /// in this property, the values in this property are preferred.
    var headerFields: [String: String] { get }

    /// The parser object that states `Content-Type` to accept and parses response body.
    var dataParser: DataParser { get }

    /// Intercepts `URLRequest` which is created by `Request.buildURLRequest()`. If an error is
    /// thrown in this method, the result of `Session.send()` turns `.failure(.requestError(error))`.
    /// - Throws: `Error`
    func intercept(urlRequest: URLRequest) throws -> URLRequest

    /// Intercepts response `Any` and `HTTPURLResponse`. If an error is thrown in this method,
    /// the result of `Session.send()` turns `.failure(.responseError(error))`.
    /// The default implementation of this method is provided to throw `ResponseError.unacceptableStatusCode`
    /// if the HTTP status code is not in `200..<300`.
    /// - Throws: `Error`
    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any

    /// Build `Response` instance from raw response object. This method is called after
    /// `intercept(object:urlResponse:)` if it does not throw any error.
    /// - Throws: `Error`
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response
}

public extension Request {
    var parameters: Any? {
        return nil
    }

    var queryParameters: QueryParameters? {
        guard let parameters = parameters, method.prefersQueryParameters else {
            return nil
        }

        return URLEncodedQueryParameters(parameters: parameters)
    }

    var bodyParameters: BodyParameters? {
        guard let parameters = parameters, !method.prefersQueryParameters else {
            return nil
        }

        return JSONBodyParameters(JSONObject: parameters)
    }

    var headerFields: [String: String] {
        return [:]
    }

    var dataParser: DataParser {
        return JSONDataParser(readingOptions: [])
    }

    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func intercept(object: Any, urlResponse: HTTPURLResponse) throws -> Any {
        guard 200..<300 ~= urlResponse.statusCode else {
            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }

    /// Builds `URLRequest` from properties of `self`.
    /// - Throws: `RequestError`, `Error`
    func buildURLRequest() throws -> URLRequest {
        let url = path.isEmpty ? baseURL : baseURL.appendingPathComponent(path)
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw RequestError.invalidBaseURL(baseURL)
        }

        var urlRequest = URLRequest(url: url)

        if let queryString = queryParameters?.encode(), !queryString.isEmpty {
            components.percentEncodedQuery = queryString
        }

        if let bodyParameters = bodyParameters {
            urlRequest.setValue(bodyParameters.contentType, forHTTPHeaderField: "Content-Type")

            switch try bodyParameters.buildEntity() {
            case .data(let data):
                urlRequest.httpBody = data

            case .inputStream(let inputStream):
                urlRequest.httpBodyStream = inputStream
            }
        }

        urlRequest.url = components.url
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue(dataParser.contentType, forHTTPHeaderField: "Accept")

        headerFields.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        return (try intercept(urlRequest: urlRequest) as URLRequest)
    }

    /// Builds `Response` from response `Data`.
    /// - Throws: `ResponseError`, `Error`
    func parse(data: Data, urlResponse: HTTPURLResponse) throws -> Response {
        let parsedObject = try dataParser.parse(data: data)
        let passedObject = try intercept(object: parsedObject, urlResponse: urlResponse)
        return try response(from: passedObject, urlResponse: urlResponse)
    }
}

public extension Request where Response == Void {
    func response(from object: Any, urlResponse: HTTPURLResponse) throws {
        return
    }
}
