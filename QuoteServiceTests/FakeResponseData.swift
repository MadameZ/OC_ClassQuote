//
//  FakeResponseData.swift
//  QuoteServiceTests
//
//  Created by Morgan on 08/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

// simulate fake responses to a call from a server
// structure follows parameters data, response, error of the completion handler closure :
// task = session.dataTask(with: request) { (data, response, error) in ... see QuoteService

class FakeResponseData {
    // MARK: - Data
    // get data from Quote.json
    static var quoteCorrectData: Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Quote", withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    // simulate invalid data
    static let quoteIncorrectData = "erreur".data(using: .utf8)!
    static let imageData = "image".data(using: .utf8)!

    // MARK: - Response
    // simulate HTTP status codes
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!


    // MARK: - Error
    class QuoteError: Error {}
    static let error = QuoteError()
}

