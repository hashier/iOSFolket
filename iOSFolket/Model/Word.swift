//
//  Word.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 10/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import RealmSwift

class Word: Object {
    dynamic var language = ""
    dynamic var wordClass = ""
    dynamic var value = ""
    var translations = List<Translation>()
}
