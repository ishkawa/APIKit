# APIKit 3 Migration Guide

APIs of APIKit are redesigned to follow [Swift 3 API design guidelines](https://swift.org/documentation/api-design-guidelines/). This major version changes interface only, and all functionalities are same as APIKit 2.

**NOTE:** Make sure that all old protocol methods are replaced by the new method. Especially, methods which has default implementation such as `interceptURLRequest(_:)` and `interceptObject(_:URLResponse:)`, because Swift compiler cannot warn that existing method is no longer a member of any protocol. To find this kind of old methods, search project with keyword `interceptURLRequest` and `interceptObject`.

## Name of protocols

- [**Renamed**] `RequestType` → `Request`
- [**Renamed**] `SessionAdapterType` → `SessionAdapter`
- [**Renamed**] `SessionTaskType` → `SessionTask`
- [**Renamed**] `BodyParametersType` → `BodyParameters`
- [**Renamed**] `DataParserType` → `DataParser`

## Request

- [**Renamed**] `interceptURLRequest(_:)` → `intercept(urlRequest:)`
- [**Renamed**] `interceptObject(_:URLResponse:)` → `intercept(object:urlResponse:)`
- [**Renamed**] `responseFromObject(_:URLResponse:)` → `response(from:urlResponse:)`

## Session

- [**Renamed**] `sharedSession` → `shared`
- [**Renamed**] `sendRequest(_:callbackQueue:handler:)` → `send(_:callbackQueue:handler:)`
- [**Renamed**] `cancelRequest(_:passingTest:)` → `cancelRequests(with:passingTest:)`

## HTTPMethod

- [**Renamed**] `GET` → `get`
- [**Renamed**] `POST` → `post`
- [**Renamed**] `PUT` → `put`
- [**Renamed**] `HEAD` → `head`
- [**Renamed**] `DELETE` → `delete`
- [**Renamed**] `PATCH` → `patch`
- [**Renamed**] `TRACE` → `trace`
- [**Renamed**] `OPTIONS` → `options`
- [**Renamed**] `CONNECT` → `connect`

## CallbackQueue

- [**Renamed**] `Main` → `main`
- [**Renamed**] `SessionQueue` → `sessionQueue`
- [**Renamed**] `OperationQueue` → `operationQueue`
- [**Renamed**] `DispatchQueue` → `dispatchQueue`

## SessionAdapter

- [**Renamed**] `createTaskWithURLRequest(_:handler:)` → `createTask(with:handler:)`
- [**Renamed**] `getTasksWithHandler(_:)` → `getTasks(with:)`

## DataParser

- [**Renamed**] `parseData(_:)` → `parse(data:)`

## SessionTaskError

- [**Renamed**] `ConnectionError` → `connectionError`
- [**Renamed**] `RequestError` → `requestError`
- [**Renamed**] `ResponseError` → `responseError`

## RequestError

- [**Renamed**] `InvalidBaseURL` → `invalidBaseURL`
- [**Renamed**] `UnexpectedURLRequest` → `unexpectedURLRequest`

## ResponseError

- [**Renamed**] `NonHTTPURLResponse` → `nonHTTPURLResponse`
- [**Renamed**] `UnacceptableStatusCode` → `unacceptableStatusCode`
- [**Renamed**] `UnexpectedObject` → `unexpectedObject`
