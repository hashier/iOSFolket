//
//  ViewController.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 08/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit

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
        
        let file = NSBundle.mainBundle().pathForResource("small", ofType: "xml")
        if let file = file {
            let fxmlp = FolketXMLParser(withFilePath: file)
            if let dictionary = fxmlp.parse() {
                print(dictionary) // comment that out after parrsing is done
                // TODO: save this dictionary to disk
            } else {
                // TODO: parsing errors
            }
        }
        
    }
}

