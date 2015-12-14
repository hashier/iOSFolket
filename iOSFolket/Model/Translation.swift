//
//  Translation.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 14/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import UIKit
import RealmSwift

class Translation: Object {
    dynamic var original: LanguageUnit?
    dynamic var translation: LanguageUnit?
}
