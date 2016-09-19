//
//  Deprecated.swift
//  APIKit
//
//  Created by Yosuke Ishikawa on 9/19/16.
//  Copyright © 2016 Yosuke Ishikawa. All rights reserved.
//

import Result

// MARK: - Protocols

@available(*, deprecated, renamed: "Request")
public typealias RequestType = Request

@available(*, deprecated, renamed: "SessionAdapter")
public typealias SessionAdapterType = SessionAdapter

@available(*, deprecated, renamed: "SessionTask")
public typealias SessionTaskType = SessionTask

@available(*, deprecated, renamed: "BodyParameters")
public typealias BodyParametersType = BodyParameters

@available(*, deprecated, renamed: "DataParser")
public typealias DataParserType = DataParser

// MARK: Session

extension Session {
    @available(*, deprecated, renamed: "shared")
    public class var sharedSession: Session {
        return shared
    }
    
    @available(*, deprecated, renamed: "send(_:callbackQueue:handler:)")
    @discardableResult
    public class func sendRequest<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        return send(request, callbackQueue: callbackQueue, handler: handler)
    }

    @available(*, deprecated, renamed: "send(_:callbackQueue:handler:)")
    @discardableResult
    public func sendRequest<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        return send(request, callbackQueue: callbackQueue, handler: handler)
    }

    @available(*, deprecated, renamed: "cancelRequests(with:passingTest:)")
    public class func cancelRequest<Request: APIKit.Request>(_ requestType: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) {
        cancelRequests(with: requestType, passingTest: test)
    }

    @available(*, deprecated, renamed: "cancelRequests(with:passingTest:)")
    public func cancelRequest<Request: APIKit.Request>(_ requestType: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) {
        cancelRequests(with: requestType, passingTest: test)
    }
}
