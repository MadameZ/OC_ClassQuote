//
//  ViewController.swift
//  ClassQuote
//
//  Created by Morgan on 06/10/2018.
//  Copyright © 2018 Morgan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newQuoteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!


    @IBAction func tappedNewQuoteButton(_ sender: Any) {
          
        toggleActivityIndicator(shown: true)
        
        /// on réceptionne les fonctions callback dans le controller
        /// c'est à partir de shared qu'on fait systématiqument l'appel à getQuote
        QuoteService.shared.getQuote { (success, quote) in
            self.toggleActivityIndicator(shown: false)
            
            if success, let quote = quote {
                /// On affiche la citation
                self.update(quote: quote)
            } else {
               self.presentAlert()
            }
        }
    }
    
    // MARK: - ActivityIndicator
    /// pour que l'utilisateur ne puisse pas lancer 2 appels en même temps
    
    private func toggleActivityIndicator(shown: Bool) {
        activityIndicator.isHidden = !shown
        newQuoteButton.isHidden = shown
    }

    // MARK: - update quote
    private func update(quote: Quote) {
        quoteLabel.text = quote.text
        authorLabel.text = quote.author
        imageView.image = UIImage(data: quote.imageData!)
    }

    // MARK: - presentAlert
    private func presentAlert() {
        let alertVC = UIAlertController(title: "Error", message: "The quote download failed.", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

