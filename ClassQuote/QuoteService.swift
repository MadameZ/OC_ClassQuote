//
//  QuoteService.swift
//  ClassQuote
//
//  Created by Morgan on 06/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

class QuoteService {
    
    // singleton pattern est une propriété statique de type QuoteService. On nomme shared l'instance unique, c'est elle qui va être partagée
    // - on protège la classe en rendant privé l'initialiseur par défaut. On ne peut plus écrire QuoteService() à l'extérieur de la classe
    static var shared = QuoteService()
    private init() {}

    private static let quoteURL = URL(string: "https://api.forismatic.com/api/1.0/")!
    private static let pictureURL = URL(string: "https://source.unsplash.com/random/1000x1000")!
    // on retravaille sur le même objet tâche
    private var task: URLSessionDataTask?

    // instance de URLSession avec configuration par défaut :
    private var quoteSession = URLSession(configuration: .default)
    private var imageSession = URLSession(configuration: .default)
    
    init(quoteSession: URLSession, imageSession: URLSession) {
        self.quoteSession = quoteSession
        self.imageSession = imageSession
    }
    
    
    // MARK: - création de la requête
 
    private static func createQuoteRequest() -> URLRequest {
           // create request
           var request = URLRequest(url: quoteURL)
           // attach http method
           request.httpMethod = "POST"

           // create body
           let body = "method=getQuote&format=json&lang=en"
           // encode body using utf8 and attach it to request
           request.httpBody = body.data(using: .utf8)

           return request
       }
    
    
    // MARK: - récupérer la citation
    
    func getQuote(callback: @escaping (Bool, Quote?) -> Void) {
        
        // créé request en utilisant la classe car ce sont des propriétés statiques
        let request = QuoteService.createQuoteRequest()
        
        // si j'ai déjà un appel en cour, je l'annule
        task?.cancel()
        
        // create task for the session
        task = quoteSession.dataTask(with: request) { (data, response, error) in
            // DispatchQueue.main.async :Tout s'effectue dans la queue principal :
            DispatchQueue.main.async {
                // gestion de la response
                // check error :
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                // check HTTP status :
                // - sous-classe de HTTPURLResponse : URLResponse
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }
                // decode response :
                // - decode([String: String].self : le type qu'on attend après avoir décodé le JSON et self pour avoir le type en lui même
                guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
                    let text = responseJSON["quoteText"], let author = responseJSON["quoteAuthor"] else {
                        callback(false, nil)
                        return
                }
                // récupérer l'image après la citation
                // comme on veut tout envoyer au controller il faut rassembler les données de la citation et de l'image => fermeture pour getImage
                self.getImage { (data) in
                    // on veut renvoyer notre callback
                    if let data = data {
                        // on construit l'objet quote
                        let quote = Quote(text: text, author: author, imageData: data)
                        // On envoie le callback true : la requête a russi
                        callback(true, quote)
                    } else {
                        callback(false, nil)
                    }
                }
            }
        }
        
        // lance la tâche
        task?.resume()
    }


   // MARK: - get images
    
    // On rajoute une fermeture à la fonction qui prend des data de manière optionnel et qui ne renvoie rien
    
    private func getImage(completionHandler: @escaping ((Data?) -> Void)) {
        
         // si j'ai déjà un appel en cour, je l'annule
        task?.cancel()
        
        // autres forme de dataTask car c'est une requête GET et  il n'y a pas de paramètre à passer
        task = imageSession.dataTask(with: QuoteService.pictureURL) { (data, response, error) in
            // DispatchQueue.main.async : Tout s'effectue dans la queue principal :
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
