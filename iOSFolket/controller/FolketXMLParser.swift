//
//  FolketXMLParser.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 12/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import SWXMLHash

enum FolketXMLParserError: ErrorType {
    case ParsingError
}

enum FolketXMLParserResultType {
    case Success(dictionary: Dictionary)
    case Error(error: FolketXMLParserError)
}

class FolketXMLParser {
    var filePath: String
    
    init(withFilePath: String) {
        filePath = withFilePath
    }
    
    func parse(completion: (result: FolketXMLParserResultType) -> Void) -> Void {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            let dictionary = self.parse()
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let dictionary = dictionary {
                    completion(result: .Success(dictionary: dictionary))
                } else {
                    completion(result: .Error(error: .ParsingError))
                }
            })
        }
    }
    
    func parse() -> Dictionary? {
        
        var xmlStr = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        func parseDictionary(childDictionary: XMLIndexer) -> Dictionary? {
            
            guard let dictionaryElement = childDictionary.element else {
                return nil;
            }
            
            let dictionary = Dictionary()
            
            dictionary.sourceLanguage = dictionaryElement.attributes["source-language"]!
            dictionary.targetLanguage = dictionaryElement.attributes["target-language"]!
            
            dictionary.comment = dictionaryElement.attributes["comment"]
            dictionary.name = dictionaryElement.attributes["name"]
            dictionary.version = dictionaryElement.attributes["version"]
            dictionary.license = dictionaryElement.attributes["license"]
            dictionary.licenseComment = dictionaryElement.attributes["licenseComment"]
            dictionary.originURL = dictionaryElement.attributes["originURL"]
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let created = dictionaryElement.attributes["created"] {
                dictionary.created = dateFormatter.dateFromString(created)
            }
            if let lastChanged = dictionaryElement.attributes["last-changed"] {
                dictionary.created = dateFormatter.dateFromString(lastChanged)
            }
            
            for child in childDictionary.children {
                switch child.element!.name {
                case "word":
                    if let word = parseWord(child, targetLanguage: dictionary.targetLanguage) {
                        dictionary.words.append(word)
                    }
                default:
                    print("NOT PARSED : \(child)")
                }
            }
            
            return dictionary;
        }
        
        func parseWord(childWord: XMLIndexer, targetLanguage: String) -> Word? {
            
            guard let wordElement = childWord.element else {
                return nil
            }
            
            let value = wordElement.attributes["value"]
            let language = wordElement.attributes["lang"]
            let wordClass = wordElement.attributes["class"]
            let word = Word()
            
            word.value = value!
            word.language = language!
            
            word.wordClass = wordClass
            
            for wordChild in childWord.children {
                switch wordChild.element!.name {
                case "phonetic":
                    word.phonetic = parseLanguageUnit(wordChild, language: word.language)
                case "definition":
                    word.definition = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                case "translation":
                    if let languageUnit = parseLanguageUnit(wordChild, language: targetLanguage) {
                        word.translations.append(languageUnit)
                    }
                case "synonym":
                    if let languageUnit = parseLanguageUnit(wordChild, language: word.language) {
                        word.synonyms.append(languageUnit)
                    }
                case "paradigm":
                    for paradigms in wordChild.all {
                        if let languageUnit = parseLanguageUnit(paradigms, language: word.language) {
                            word.inflections.append(languageUnit)
                        }
                    }
                case "example":
                    if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                        word.examples.append(translation)
                    }
                case "compound":
                    if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                        word.compounds.append(translation)
                    }
                case "idiom":
                    if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                        word.idioms.append(translation)
                    }
                case "derivation":
                    if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                        word.derivations.append(translation)
                    }
                case "explanation":
                    word.explanation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                case "grammar":
                    word.grammar = parseLanguageUnit(wordChild, language: word.language)
                case "related":
                    if wordChild.element?.attributes["type"] == "antonym" {
                        if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                            word.antonyms.append(translation)
                        }
                    } else {
                        print("NOT PARSED <related> type: \(wordChild.element?.attributes["type"])")
                    }
                default:
                    print("NOT PARSED : \(wordChild)")
                }
            }
            
            return word
        }
        
        func parseLanguageUnit(childLanguageUnit: XMLIndexer, language: String) -> LanguageUnit? {
            guard let value = childLanguageUnit.element?.attributes["value"] else {
                return nil
            }
            
            let languageUnit = LanguageUnit()
            languageUnit.language = language;
            languageUnit.value = value;
            
            return languageUnit;
        }
        
        func parseTranslation(childTranslation: XMLIndexer, language: String, targetLanguage: String) -> Translation? {
            guard let value = childTranslation.element?.attributes["value"]  else {
                return nil
            }
            
            let translation = Translation()
            
            let original = LanguageUnit();
            original.value = value;
            original.language = language;
            
            translation.original = original
            translation.translation = parseLanguageUnit(childTranslation["translation"], language: targetLanguage);
            
            
            return translation;
        }
        
        let xml = SWXMLHash.parse(xmlStr)
        
        let dictionary = parseDictionary(xml["dictionary"])
        
        return dictionary;
    }
}