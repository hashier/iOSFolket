//
//  Translation.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 11/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import RealmSwift

class LanguageUnit: Object {
    dynamic var language = ""
    dynamic var value = ""
    dynamic var normalizedValue = ""
    
    convenience init(language:String, value:String) {
        self.init()
        
        self.language = language
        self.value = value
        normalizedValue = value.normalizedString
    }
}
