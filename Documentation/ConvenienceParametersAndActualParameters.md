# Convenience Parameters and Actual Parameters

To satisfy both ease and accuracy, `RequestType` has 2 kind of parameters properties, convenience property and actual properties. If you implement convenience parameters only, actual parameters are computed by default implementation of `RequestType`.

1. [Convenience parameters](#convenience-parameters)
2. [Actual parameters](#actual-parameters)

## Convenience parameters

Most documentations of web APIs express parameters in dictionary-like notation:

|Name   |Type    |Description                                                                                      |
|-------|--------|-------------------------------------------------------------------------------------------------|
|`q`    |`string`|The search keywords, as well as any qualifiers.                                                  |
|`sort` |`string`|The sort field. One of `stars`, `forks`, or `updated`. Default: results are sorted by best match.|
|`order`|`string`|The sort order if `sort` parameter is provided. One of `asc` or `desc`. Default: `desc`          |

 `RequestType` has a property `var parameter: AnyObject?` to express parameters in this kind of notation. That is the convenience parameters.

```swift
struct SomeRequest: RequestType {
    ...

    var parameters: AnyObject? {
        return [
            "q": "Swift",
            "sort": "stars",
            "order": "desc",
        ]
    }
}
```

`RequestType` provides default implementation of `parameters` `nil`.

```swift
public extension RequestType {
    public var parameters: AnyObject? {
        return nil
    }
}
```

## Actual parameters

Actually, we have to translate dictionary-like notation in API docs into HTTP/HTTPS request. There are 2 places to express parameters, URL query and body. `RequestType` has interface to express them, `var queryParameters: [String: AnyObject]?` and `var bodyParameters: BodyParametersType?`. Those are the actual parameters.

If you implement convenience parameters only, the actual parameters are computed from the convenience parameters depending on HTTP method. Here is the default implementation of actual parameters:

```swift
public extension RequestType {
    public var queryParameters: [String: AnyObject]? {
        guard let parameters = parameters as? [String: AnyObject] where method.prefersQueryParameters else {
            return nil
        }

        return parameters
    }

    public var bodyParameters: BodyParametersType? {
        guard let parameters = parameters where !method.prefersQueryParameters else {
            return nil
        }

        return JSONBodyParameters(JSONObject: parameters)
    }
}
```

If you implement actual parameters for the HTTP method, the convenience parameters will be ignored.

### BodyParametersType

There are several MIME types to express parameters such as `application/json`, `application/x-www-form-urlencoded` and `multipart/form-data; boundary=foobarbaz`. Because parameters types to express these MIME types are different, type of `bodyParameters` is a protocol `BodyParametersType`.

`BodyParametersType` defines 2 components, `contentType` and `buildEntity()`. You can create custom body parameters type that conforms to `BodyParametersType`.

```swift
public enum RequestBodyEntity {
    case Data(NSData)
    case InputStream(NSInputStream)
}

public protocol BodyParametersType {
    var contentType: String { get }
    func buildEntity() throws -> RequestBodyEntity
}
```

APIKit provides 3 body parameters type listed below:

|Name                             |Parameters Type                         |
|---------------------------------|----------------------------------------|
|`JSONBodyParameters`             |`AnyObject`                             |
|`FormURLEncodedBodyParameters`   |`[String: AnyObject]`                   |
|`MultipartFormDataBodyParameters`|`[MultipartFormDataBodyParameters.Part]`|
