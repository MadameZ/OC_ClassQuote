//
//  URLSessionFake.swift
//  QuoteServiceTests
//
//  Created by Morgan on 09/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

// double URLSession to adress dataTask(with url:...) and dataTask(with request:...) tests
class URLSessionFake: URLSession {
    //completion handler properties
    var data: Data?
    var response: URLResponse?
    var error: Error?

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let task = URLSessionDataTaskFake()
        task.completionHandler = completionHandler
        task.data = data
        task.urlResponse = response
        task.responseError = error
        return task
    }

    override func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let task = URLSessionDataTaskFake()
        task.completionHandler = completionHandler
        task.data = data
        task.urlResponse = response
        task.responseError = error
        return task
    }
}

// double URLSessionDataTask to adress resume() and cancel() tests
class URLSessionDataTaskFake: URLSessionDataTask {
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    var data: Data?
    var urlResponse: URLResponse?
    var responseError: Error?

    override func resume() {
        completionHandler?(data, urlResponse, responseError)
    }

    override func cancel() {}
}
