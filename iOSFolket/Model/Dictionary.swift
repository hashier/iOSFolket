//
//  Dictionary.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 14/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import RealmSwift

class Dictionary: Object {
    dynamic var sourceLanguage = ""
    dynamic var targetLanguage = ""
    
    dynamic var created: NSDate?
    dynamic var lastChanged: NSDate?
    
    dynamic var name: String?
    dynamic var comment: String?
    dynamic var version: String?
    dynamic var license: String?
    dynamic var licenseComment: String?
    dynamic var originURL: String?
    
    var words = List<Word>()
}
