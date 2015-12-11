//
//  ViewController.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 08/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import SWXMLHash

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        test()
    }
    
    func test() {
        
        let file = NSBundle.mainBundle().pathForResource("small", ofType: "xml")
        var xmlStr = try! String(contentsOfFile: file!, encoding: NSUTF8StringEncoding)
        
        func parseDictionary(dictionary: XMLIndexer) -> [Word] {
            return dictionary["word"].map(parseWord)
        }
        
        func parseWord(childWord: XMLIndexer) -> Word {
            let value = childWord.element?.attributes["value"]
            let language = childWord.element?.attributes["lang"]
            let wordClass = childWord.element?.attributes["class"]
            let word = Word()

            word.value = value!
            word.language = language!
            if let wordClass = wordClass {
                word.wordClass = wordClass
            }
            
            for childTranslation in childWord["translation"].all {
                let translation = parseTranslation(childTranslation, original: word.value)
                word.translations.append(translation)
            }
            
            return word
        }
        
        func parseTranslation(childTranslation: XMLIndexer, original: String) -> Translation {
            let value = childTranslation.element?.attributes["value"]
            let translation = Translation()
            translation.original = original;
            translation.translation = value!;
            
            return translation;
        }
        
        let xml = SWXMLHash.parse(xmlStr)
        
        let words = parseDictionary(xml["dictionary"])
        
        print(words);

    }

}

