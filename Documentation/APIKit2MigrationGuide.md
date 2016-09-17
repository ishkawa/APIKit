# APIKit 2 Migration Guide

APIKit 2.0 introduces several breaking changes to add functionality and to improve modeling of web API.

- Abstraction of backend
- Improved error handling modeling
- Separation of convenience parameters and type-safe parameters

## Errors

- [**Deleted**] `APIError`
- [**Added**] `SessionTaskError`

Errors cases of `Session.sendRequest(_:handler:)` is reduced to 3 cases listed below:

```swift
public enum SessionTaskError: ErrorType {
    /// Error of networking backend such as `NSURLSession`.
    case ConnectionError(ErrorType)

    /// Error while creating `NSURLRequest` from `Request`.
    case RequestError(ErrorType)

    /// Error while creating `RequestType.Response` from `(NSData, NSURLResponse)`.
    case ResponseError(ErrorType)
}
```

These error cases describes *where* the error occurred, not *what* is the error. You can throw any kind of error while building `NSURLRequest` and converting `NSData` to `Response`. `Session` catches the error you threw and wrap it into one of the cases defined in `SessionTaskError`. For example, if you throw `SomeError` in `responseFromObject(_:URLResponse:)`, the closure of `Session.sendRequest(_:handler:)` receives `.Failure(.ResponseError(SomeError))`.

## RequestType

### Converting AnyObject to Response

- [**Deleted**] `func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> Response?`
- [**Added**] `func responseFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> Response`

### Handling response errors

In 1.x, `Session` checks if the actual status code is contained in `RequestType.acceptableStatusCodes`. If it is not, `Session` calls `errorFromObject()` to obtain custom error from response object. In 2.x, `Session` always call `interceptObject()` before calling `responseFromObject()`, so you can validate `AnyObject` and `NSHTTPURLResponse` in `interceptObject()` and throw error initialized with them.

- [**Deleted**] `var acceptableStatusCodes: Set<Int> { get }`
- [**Deleted**] `func errorFromObject(object: AnyObject, URLResponse: NSHTTPURLResponse) -> ErrorType?`
- [**Added**] `func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject`

For example, the code below checks HTTP status code, and if the status code is not 2xx, it throws an error initialized with error JSON GitHub API returns.

```swift
func interceptObject(object: AnyObject, URLResponse: NSHTTPURLResponse) throws -> AnyObject {
    guard (200..<300).contains(URLResponse.statusCode) else {
        // https://developer.github.com/v3/#client-errors
        throw GitHubError(object: object)
    }

    return object
}
```

### Parameters

To satisfy both ease and accuracy, `parameters` property is separated into 1 convenience property and 2 actual properties. If you implement convenience parameters only, 2 actual parameters are computed by default implementation of `RequestType`.

- [**Deleted**] `var parameters: [String: AnyObject]`
- [**Deleted**] `var objectParameters: AnyObject`
- [**Deleted**] `var requestBodyBuilder: RequestBodyBuilder`
- [**Added**] `var parameters: AnyObject?` (convenience property)
- [**Added**] `var bodyParameters: BodyParametersType?` (actual property)
- [**Added**] `var queryParameters: [String: AnyObject]?` (actual property)

Related types:

- [**Deleted**] `enum RequestBodyBuilder`
- [**Added**] `protocol BodyParametersType`

APIKit provides 3 parameters types that conform to `BodyParametersType`:

- [**Added**] `class JSONBodyParameters`
- [**Added**] `class FormURLEncodedBodyParameters`
- [**Added**] `class MultipartFormDataBodyParameters`

### HTTP Headers

- [**Deleted**] `var HTTPHeaderFields: [String: String]`
- [**Added**] `var headerFields: [String: String]`

### Data parsers

- [**Deleted**] `var responseBodyParser: ResponseBodyParser`
- [**Added**] `var dataParser: DataParserType`

Related types:

- [**Deleted**] `enum ResponseBodyParser`
- [**Added**] `protocol DataParserType`
- [**Added**] `class JSONDataParser`
- [**Added**] `class FormURLEncodedDataParser`
- [**Added**] `class StringDataParser`

### Configuring NSURLRequest

`configureURLRequest()` in 1.x is renamed to `interceptURLRequest()` for the consistency with `interceptObject()`.

- [**Deleted**] `func configureURLRequest(URLRequest: NSMutableURLRequest) -> NSMutableURLRequest`
- [**Added**] `func interceptURLRequest(URLRequest: NSMutableURLRequest) throws -> NSMutableURLRequest`

## NSURLSession

- [**Deleted**] `class URLSessionDelegate`
- [**Added**] `protocol SessionTaskType`
- [**Added**] `protocol SessionAdapterType`
- [**Added**] `class NSURLSessionAdapter`
