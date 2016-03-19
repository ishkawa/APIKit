//
//  TestSessionAdapter.swift
//  APIKit
//
//  Created by Yosuke Ishikawa on 3/19/16.
//  Copyright © 2016 Yosuke Ishikawa. All rights reserved.
//

import Foundation
import APIKit

class TestSessionTask: SessionTaskType {
    func cancel() {

    }
}

class TestSessionAdapter: SessionAdapterType {
    var data: NSData?
    var URLResponse: NSURLResponse?
    var error: NSError?

    init(data: NSData? = nil, URLResponse: NSURLResponse? = nil, error: NSError? = nil) {
        self.data = data
        self.URLResponse = URLResponse
        self.error = error
    }

    func resumedTaskWithURLRequest(URLRequest: NSURLRequest, handler: (NSData?, NSURLResponse?, NSError?) -> Void) -> SessionTaskType {
        handler(data, URLResponse, error)
        return TestSessionTask()
    }

    func getTasksWithHandler(handler: [SessionTaskType] -> Void) {
        handler([])
    }
}
