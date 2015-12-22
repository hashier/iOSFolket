//
//  ViewController.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 08/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UITableViewController, UISearchResultsUpdating {

    let searchController = UISearchController(searchResultsController: nil)

    var 📚:WordDictionary?
    let realm = try! Realm()
    
    var filteredWords:Results<Word>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadDictionary()
        
        if 📚 == nil {
            loadDictionaryFromParser()
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadDictionary() {
        realm.refresh()
        self.📚 = realm.objects(WordDictionary).first
        self.title = (self.📚?.name ?? "")
        self.filterContentForSearchText(searchController.searchBar.text!)
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
    
    func filterContentForSearchText(searchText: String) {
        let normalizedSearchString = searchText.normalizedString
        
        let predicate = NSPredicate(format: "normalizedValue BEGINSWITH %@ OR ANY translations.normalizedValue BEGINSWITH %@ OR ANY inflections.normalizedValue BEGINSWITH %@ OR ANY variants.normalizedValue BEGINSWITH %@", normalizedSearchString, normalizedSearchString, normalizedSearchString, normalizedSearchString)
        filteredWords = realm.objects(Word).filter(predicate)
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destination = segue.destinationViewController as? WordDetailViewController {
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPathForCell(cell) {
                if let word = filteredWords?[indexPath.row] {
                    destination.word = word
                }
            }
        }
    }
    
    // MARK: UISearchResultsUpdating
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWords?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath)
        
        let word = filteredWords?[indexPath.row]
        
        cell.textLabel?.text = word?.value
        
        return cell
    }
    
}

