//
//  QuoteService.swift
//  ClassQuote
//
//  Created by Morgan on 06/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

class QuoteService {
    
    /// singleton pattern est une propriété statique de type QuoteService. On nomme shared l'instance unique, c'est elle qui va être partagée
    /// - on protège la classe en rendant innacessible et rendant privé l'initialiseur par défaut. On ne peut plus écrire QuoteService() à l'extérieur de la classe
    static var shared = QuoteService()
    private init() {}

    private static let quoteURL = URL(string: "https://api.forismatic.com/api/1.0/")!
    private static let pictureURL = URL(string: "https://source.unsplash.com/random/1000x1000")!
    
    /// on retravaille sur le même objet tâche
    private var task: URLSessionDataTask?

    /// instance de URLSession une pour la quote et une pour l'image avec configuration par défaut :
    /// - ces propriétés sont des points d'entrées pour injecter une dépendance
    /// - les test ont besoins d'accéder à ces propriétés donc on créé un initialiseur pour les mettre en privées :
    ///      Ceci limite la modification des propriétés à l'initialisation et non pendant toute la durée de vie de l'objet.
    private var quoteSession = URLSession(configuration: .default)
    private var imageSession = URLSession(configuration: .default)
    
    init(quoteSession: URLSession, imageSession: URLSession) {
        self.quoteSession = quoteSession
        self.imageSession = imageSession
    }
    
    
    // MARK: - création de la requête
    // création de la requête uniquement pour la citation car elle contient des paramètre et pas l'image
 
    private static func createQuoteRequest() -> URLRequest {
           /// create request
           var request = URLRequest(url: quoteURL)
           /// attach http method
           request.httpMethod = "POST"

           /// create body
           let body = "method=getQuote&format=json&lang=en"
           // encode body using utf8 and attach it to request
           request.httpBody = body.data(using: .utf8)

           return request
       }
    
    
    // MARK: - récupérer la citation
    /// pour les test nous allons tester que cette méthode car c'est la seule qui soit public
    
    func getQuote(callback: @escaping (Bool, Quote?) -> Void) {
        
        /// créé request en utilisant la classe car createQuoteRequest est une fonction statique :
        let request = QuoteService.createQuoteRequest()
        
        /// si j'ai déjà un appel en cour, je l'annule
        task?.cancel()
        
        /// create task for the session
        task = quoteSession.dataTask(with: request) { (data, response, error) in
            /// DispatchQueue.main.async :Tout s'effectue dans la queue principal :
            DispatchQueue.main.async {
                /// gestion de la response
                /// check error :
                guard let data = data, error == nil else {
                    callback(false, nil)
                    return
                }
                /// check HTTP status :
                /// - sous-classe de HTTPURLResponse : URLResponse
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    callback(false, nil)
                    return
                }
                /// decode response :
                /// - decode([String: String].self : le type qu'on attend après avoir décodé le JSON et self pour avoir le type en lui même
                guard let responseJSON = try? JSONDecoder().decode([String: String].self, from: data),
                    let text = responseJSON["quoteText"], let author = responseJSON["quoteAuthor"] else {
                        callback(false, nil)
                        return
                }
                /// récupérer l'image après la citation
                /// comme on veut tout envoyer an même temps au controller, il faut rassembler les données de la citation et de l'image au même endroit => fermeture pour getImage
                self.getImage { (data) in
                    /// on veut renvoyer notre callback
                    if let data = data {
                        /// on construit l'objet quote
                        let quote = Quote(text: text, author: author, imageData: data)
                        /// On envoie le callback true : la requête a réussi
                        callback(true, quote)
                    } else {
                        callback(false, nil)
                    }
                }
            }
        }
        
        /// lance la tâche
        task?.resume()
    }


   // MARK: - get images
    
    /// on rajoute une fermeture à la fonction qui prend des data de manière optionnel et qui ne renvoie rien
     
    private func getImage(completionHandler: @escaping ((Data?) -> Void)) {
        
        /// si j'ai déjà un appel en cour, je l'annule
        task?.cancel()
        
        /// autre forme de dataTask, on met juste l'url car  il n'y a pas de paramètre à passer. (on écrit QuoteService car pictureURL est une propriété statique) :
        task = imageSession.dataTask(with: QuoteService.pictureURL) { (data, response, error) in
            /// DispatchQueue.main.async : Tout s'effectue dans la queue principal :
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
