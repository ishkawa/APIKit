//
//  Unavailable.swift
//  APIKit
//
//  Created by Yosuke Ishikawa on 9/19/16.
//  Copyright © 2016 Yosuke Ishikawa. All rights reserved.
//

import Result

// MARK: - Protocols

@available(*, unavailable, renamed: "Request")
public typealias RequestType = Request

@available(*, unavailable, renamed: "SessionAdapter")
public typealias SessionAdapterType = SessionAdapter

@available(*, unavailable, renamed: "SessionTask")
public typealias SessionTaskType = SessionTask

@available(*, unavailable, renamed: "BodyParameters")
public typealias BodyParametersType = BodyParameters

@available(*, unavailable, renamed: "DataParser")
public typealias DataParserType = DataParser

// MARK: Session

extension Session {
    @available(*, unavailable, renamed: "shared")
    public class var sharedSession: Session {
        fatalError("\(#function) is no longer available")
    }
    
    @available(*, unavailable, renamed: "send(_:callbackQueue:handler:)")
    public class func sendRequest<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        fatalError("\(#function) is no longer available")
    }

    @available(*, unavailable, renamed: "send(_:callbackQueue:handler:)")
    public func sendRequest<Request: APIKit.Request>(_ request: Request, callbackQueue: CallbackQueue? = nil, handler: @escaping (Result<Request.Response, SessionTaskError>) -> Void = { _ in }) -> SessionTask? {
        fatalError("\(#function) is no longer available")
    }

    @available(*, unavailable, renamed: "cancelRequests(with:passingTest:)")
    public class func cancelRequest<Request: APIKit.Request>(_ requestType: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) {
        fatalError("\(#function) is no longer available")
    }

    @available(*, unavailable, renamed: "cancelRequests(with:passingTest:)")
    public func cancelRequest<Request: APIKit.Request>(_ requestType: Request.Type, passingTest test: @escaping (Request) -> Bool = { _ in true }) {
        fatalError("\(#function) is no longer available")
    }
}
