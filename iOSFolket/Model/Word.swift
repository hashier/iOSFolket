//
//  Word.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 10/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import RealmSwift

class Word: LanguageUnit {
    dynamic var wordClass: String?
    
    dynamic var phonetic: LanguageUnit?
    dynamic var grammar: LanguageUnit?
    
    dynamic var definition: Translation?
    dynamic var explanation: Translation?
    
    var translations = List<LanguageUnit>()
    var inflections = List<LanguageUnit>()
    var synonyms = List<LanguageUnit>()
    
    var antonyms = List<Translation>()
    var examples = List<Translation>()
    var compounds = List<Translation>()
    var derivations = List<Translation>()
    var idioms = List<Translation>()
}
