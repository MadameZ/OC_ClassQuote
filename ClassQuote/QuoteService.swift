//
//  QuoteService.swift
//  ClassQuote
//
//  Created by Morgan on 06/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

class QuoteService {
    //singleton pattern
    static var shared = QuoteService()
    private init() {}

    private static let quoteURL = URL(string: "https://api.forismatic.com/api/1.0/")!
    private static let pictureURL = URL(string: "https://source.unsplash.com/random/1000x1000")!
    private var task: URLSessionDataTask?

    // instnace de URLSession avec configuration par défaut :
    private var quoteSession = URLSession(configuration: .default)
    private var imageSession = URLSession(configuration: .default)
    
    init(quoteSession: URLSession, imageSession: URLSession) {
        self.quoteSession = quoteSession
        self.imageSession = imageSession
    }

    func getQuote(callback: @escaping (Bool, Quote?) -> Void) {
        //create request
        let request = QuoteService.createQuoteRequest()

        task?.cancel()
        //create task for the session
        task = quoteSession.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                //handle response
                //check error
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                //check HTTP status
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }
                //decode response
                guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
                    let text = responseJSON["quoteText"], let author = responseJSON["quoteAuthor"] else {
                        callback(false, nil)
                        return
                }
                // récupérer l'image
                self.getImage { (data) in
                    if let data = data {
                        // create quote bundle
                        let quote = Quote(text: text, author: author, imageData: data)
                        callback(true, quote)
                    } else {
                        callback(false, nil)
                    }
                }
            }
        }
        //launch task
        task?.resume()
    }

    private static func createQuoteRequest() -> URLRequest {
        //create request
        var request = URLRequest(url: quoteURL)
        //attach http method
        request.httpMethod = "POST"

        //create body
        let body = "method=getQuote&format=json&lang=en"
        //encode body using utf8 and attach it to request
        request.httpBody = body.data(using: .utf8)

        return request
    }

    private func getImage(completionHandler: @escaping ((Data?) -> Void)) {
        task?.cancel()
        
        task = imageSession.dataTask(with: QuoteService.pictureURL) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completionHandler(nil)
                    return
                }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    completionHandler(nil)
                    return
                }
                completionHandler(data)
            }
        }
        task?.resume()
    }
}
