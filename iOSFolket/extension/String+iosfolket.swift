//
//  String+iosfolket.swift
//  iOSFolket
//
//  Created by Emmanuel Garnier on 22/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation

extension String {
    var normalizedString: String {
        let mutableString = NSMutableString(string: self) as CFMutableStringRef
        
        let locale = CFLocaleCopyCurrent()
        
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
        CFStringLowercase(mutableString, locale)

        return mutableString as String
    }
}
