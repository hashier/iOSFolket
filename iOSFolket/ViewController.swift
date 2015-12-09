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

        let xmlWithNamespace = "<root xmlns:h=\"http://www.w3.org/TR/html4/\"" +
            "  xmlns:f=\"http://www.w3schools.com/furniture\">" +
            "  <h:table>" +
            "    <h:tr>" +
            "      <h:td>Apples</h:td>" +
            "      <h:td>Bananas</h:td>" +
            "    </h:tr>" +
            "  </h:table>" +
            "  <f:table>" +
            "    <f:name>African Coffee Table</f:name>" +
            "    <f:width>80</f:width>" +
            "    <f:length>120</f:length>" +
            "  </f:table>" +
        "</root>"
        
        var xml = SWXMLHash.parse(xmlWithNamespace)
        
        // one root element
        let count = xml["root"].all.count
        
        // "Apples"
        print(xml["root"]["h:table"]["h:tr"]["h:td"][0].element!.text!)
        
        
        // enumerate all child elements (procedurally)
        func enumerate(indexer: XMLIndexer, level: Int) {
            for child in indexer.children {
                let name = child.element!.name
                print("\(level) \(name)")
                
                enumerate(child, level: level + 1)
            }
        }
        
        enumerate(xml, level: 0)
        
        
        // enumerate all child elements (functionally)
        func reduceName(names: String, elem: XMLIndexer) -> String {
            return names + elem.element!.name + elem.children.reduce(", ", combine: reduceName)
        }
        
        print(xml.children.reduce("elements: ", combine: reduceName))
    }

}

