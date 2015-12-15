//
//  ViewController.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 08/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadDictionary()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadDictionary() {
        
        guard let file = NSBundle.mainBundle().pathForResource("small", ofType: "xml") else {
            return;
        }
        
        let fxmlp = FolketXMLParser(withFilePath: file)
        
        fxmlp.parse({ (result) -> Void in
            switch result {
            case .Success(let dictionary):
                self.saveDicitonary(dictionary)
            case .Error(let error):
                print(error)
            }
        })
    }
    
    func saveDicitonary(dictionary: Dictionary) -> Void {
        // Get the default Realm
        let realm = try! Realm()
        
        try! realm.write {
            // First we delete everything, be sure that is what we want to to
            realm.deleteAll()
            // Then we save the new dictionary
            realm.add(dictionary)
        }
        
        // Let's try to load Words to see if everything working
        let words = realm.objects(Word)
        print(words)
    }
}

