//
//  QuoteServiceTestsCase.swift
//  QuoteServiceTests
//
//  Created by Morgan on 08/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//
import Foundation

import XCTest
@testable import ClassQuote

class ClassQuoteTests: XCTestCase {
    func testGetQuoteShouldPostFailedCallback() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(data: nil, response: nil, error: FakeResponseData.error),
            /// Puisque  qu'on sait que le téléchargement échoue => nil
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        /// On a un micro décalage car on n'est pas dans la meme queue donc on fait une expectation. Les expectation servent à attendre.
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }
        /// le micro délais 0.01 ne va pas ralentir nos tests.
        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedCallbackIfNoData() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(data: nil, response: nil, error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedCallbackIfIncorrectResponse() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteCorrectData,
                response: FakeResponseData.responseKO,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedCallbackIfIncorrectData() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteIncorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedNotificationIfNoPictureData() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(data: nil, response: nil, error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedNotificationIfErrorWhileRetrievingPicture() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseOK,
                error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostFailedNotificationIfIncorrectResponseWhileRetrievingPicture() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseKO,
                error: FakeResponseData.error))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertFalse(success)
            XCTAssertNil(quote)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }

    func testGetQuoteShouldPostSuccessCallbackIfNoErrorAndCorrectData() {
        // Given
        let quoteService = QuoteService(
            quoteSession: URLSessionFake(
                data: FakeResponseData.quoteCorrectData,
                response: FakeResponseData.responseOK,
                error: nil),
            imageSession: URLSessionFake(
                data: FakeResponseData.imageData,
                response: FakeResponseData.responseOK,
                error: nil))

        // When
        let expectation = XCTestExpectation(description: "Wait for queue change.")
        quoteService.getQuote { (success, quote) in
            // Then
            XCTAssertTrue(success)
            XCTAssertNotNil(quote)

            let text = "Difficulties are things that show a person what they are.  "
            let author = "Epictetus "
            let imageData = "image".data(using: .utf8)!

            XCTAssertEqual(text, quote!.text)
            XCTAssertEqual(author, quote!.author)
            XCTAssertEqual(imageData, quote!.imageData)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 0.01)
    }
}
