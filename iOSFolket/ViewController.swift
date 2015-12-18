//
//  ViewController.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 08/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController {

    var 📚:WordDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadDictionary()
        loadDictionaryFromParser()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadDictionary() {
        let realm = try! Realm()
        self.📚 = realm.objects(WordDictionary).first
        self.tableView.reloadData()
        self.title = (self.📚?.name ?? "")
    }
    
    func loadDictionaryFromParser() {
        guard let file = NSBundle.mainBundle().pathForResource("small", ofType: "xml") else {
            return;
        }
        
        let fxmlp = FolketXMLParser(withFilePath: file)
        
        fxmlp.parse({ (result) -> Void in
            switch result {
            case .Success(_):
                self.loadDictionary()
            case .Error(let error):
                print(error)
            }
        })
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 📚?.words.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath)
        
        let word = 📚?.words[indexPath.row]
        
        cell.textLabel?.text = word?.value
        
        return cell
    }
}

