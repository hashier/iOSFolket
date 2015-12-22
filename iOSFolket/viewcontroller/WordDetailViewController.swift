//
//  WordDetailViewController.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 22/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit

class WordDetailViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!

    var word: Word!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = word.value
        
        let htmlString = self.htmlString()
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func htmlString() -> String {
        
        var htmlString = "<html><body>"
        
        htmlString += "<h1>\(word.value)</h1>"
        
        if let phonetic = word.phonetic {
            htmlString += "Phonetic: (\(phonetic.value))<br/>"
        }
        
        if let definition = word.definition {
            htmlString += "<p>"
            if let original = definition.original {
                htmlString += original.value
            }
            if let translation = definition.translation {
                htmlString += " (\(translation.value))"
            }
            htmlString += "</p>"
        }
        
        if let definition = word.explanation {
            htmlString += "<p>"
            if let original = definition.original {
                htmlString += original.value
            }
            if let translation = definition.translation {
                htmlString += " (\(translation.value))"
            }
            htmlString += "</p>"
        }
        
        htmlString += "</html></body>"
        
        htmlString += "<h2>Translations:</h2>"
        for (index, translation) in word.translations.enumerate() {
            htmlString += "\(index + 1). \(translation.value)<br/>"
        }

        return htmlString
    }
}
