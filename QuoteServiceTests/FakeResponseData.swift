//
//  FakeResponseData.swift
//  QuoteServiceTests
//
//  Created by Morgan on 08/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import Foundation

/// Pour récupérer les données de Quote.json et les utiliser dans nos test on crée la classe FakeResponseData
/// - Le rôle de FakeResponseData est de gérer les données de test
/// - Pour simuler la réponse des 2 API nous devons simuler les 3 paramètres de la réponse : data, response, error de la classe QuoteService pour chaque appel


class FakeResponseData {
    
    // MARK: - Simule Data
    /// 1- On simule le json renvoyé par Forismatic :
    ///     let bundle : on récupère le paquet dans lequel se trouve notre fichier de données
    ///     Il y a 2 bundle dans le projet, un par target donc un bundle pour les tests et un bundle pour l'application
    ///     let url : on cherche ensuite le nom et l'extension du fichier qu'on veut
    ///     return : on utilise l'initialisation de Data avec le paramètre  contentsOf puis récupère les données contenu dans cet url
    ///
    /// 2- On simule un json endommagé. Pour ça on simule des donnnées qui n'ont rien à voir avec un fichier json
    ///     on crée une constante de type data dans laquel on met la valeur de notre choix.
    ///     on simule de fausse données avec l'encodage des string.
    ///     ici on encode le string "erreur" puis encoder ce string avec data. Donc elle renvoie une valeur de type data qui n'a rien à voir avec un json
    ///
    /// 3- On simule les données de l'image. Pour ça on fait exactement la même chose que précédemment
    
    // simule le json renvoyé par Forismatic
    static var quoteCorrectData: Data? {
        let bundle = Bundle(for: FakeResponseData.self)
        let url = bundle.url(forResource: "Quote", withExtension: "json")!
        return try! Data(contentsOf: url)
    }

    // simule le json endommagé
    static let quoteIncorrectData = "erreur".data(using: .utf8)!
    
    // simule les données de l'image
    static let imageData = "image".data(using: .utf8)!

    
    
    
    // MARK: - Simule Response
    /// crée 2 instances de HTTPURLResponse. Une qui a pour code 200 (cas où tout va bien) et une à 500(cas où ça ne fonctionne pas)
    /// - on écrit n'importe qu'elle URL, il n'y a que le code de status qui nous interesse
    
    static let responseOK = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 200, httpVersion: nil, headerFields: [:])!

    static let responseKO = HTTPURLResponse(
        url: URL(string: "https://openclassrooms.com")!,
        statusCode: 500, httpVersion: nil, headerFields: [:])!


    
    
    // MARK: - Simule Error
    /// on s'interesse à la présence ou non d'une erreur
    /// - on créé une classe QuoteError qui implémente le protocole Error pour en avoir une instnace
    ///  car on ne peut pas obtenir directement une instance du protocole Error
    /// - on créé ensuite l'erreur
    
    class QuoteError: Error {}
    
    static let error = QuoteError()
    
    
}

