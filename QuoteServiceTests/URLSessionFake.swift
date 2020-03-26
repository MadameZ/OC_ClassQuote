//
//  URLSessionFake.swift
//  QuoteServiceTests
//
//  Created by Morgan on 09/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

/// on double les classes responsable de l'appel réseau ainsi que les méthodes dont le code a besoin pour fonctionner
/// - on créé URLSessionFake qui hérite de URLSession. La méthode a doubler est func dataTask()
/// - on créé aussi URLSessionDataTaskFake qui hérite de URLSessionDataTask. Les méthodes a doubler sont func resume(), func cancel()

// MARK: - URLSessionFake

class URLSessionFake: URLSession {

    var data: Data?
    var response: URLResponse?
    var error: Error?

    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    /// j'initialise URLSessionFake avec les paramètres de mon bloc de retour
    init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        /// on crée une instance de URLSesionDataTaskFake pour utiliser notre double
        let task = URLSessionDataTaskFake()
        task.completionHandler = completionHandler
        task.data = data
        task.urlResponse = response
        task.responseError = error
        return task
    }
    
    /// variante de la fonction dataTask qui utilise URLRequest
    override func dataTask(with request: URLRequest, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let task = URLSessionDataTaskFake()
        task.completionHandler = completionHandler
        task.data = data
        task.urlResponse = response
        task.responseError = error
        return task
    }
}

// MARK: - URLSessionDataTaskFake qui le double de URLSessionDataTask
/// Il simule le comportement de URLSessionDataTask mais qui ne veut pas lancer l'appel

class URLSessionDataTaskFake: URLSessionDataTask {
    
    /// var completionHandler sera le bloc de retour : c'est une propriété qui aura le type du bloc de retour
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    var data: Data?
    var urlResponse: URLResponse?
    var responseError: Error?

    /// comme ici c'est instantané, elle ne doit pas lancer l'appel mais appeler directement le bloc de retour avec les données de la réponse c'est à dire
    /// le bloc à partir de (data, response, error) in -> jusq'à task?.resume() dans la func getQuote
    override func resume() {
        completionHandler?(data, urlResponse, responseError)
    }
    
    /// il n'y aura jamais d'appel en cours a annuler car cela aura lieu instantanément donc on laisse vide
    override func cancel() {}
}
