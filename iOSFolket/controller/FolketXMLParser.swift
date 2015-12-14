//
//  FolketXMLParser.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 12/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import SWXMLHash

class FolketXMLParser {
    var filePath: String
    
    init(withFilePath: String) {
        filePath = withFilePath
    }
    
    func parse() {
        
        var xmlStr = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        func parseDictionary(dictionary: XMLIndexer) {
            
            let targetLanguage = dictionary.element?.attributes["target-language"]
            
            for childWord in dictionary["word"].all {
                let word = parseWord(childWord, targetLanguage: targetLanguage!)
                print(word)
            }
        }
        
        func parseWord(childWord: XMLIndexer, targetLanguage: String) -> Word {
            
            let value = childWord.element?.attributes["value"]
            let language = childWord.element?.attributes["lang"]
            let wordClass = childWord.element?.attributes["class"]
            let word = Word()
            
            word.value = value!
            word.language = language!
            
            word.wordClass = wordClass
            
            for wordChild in childWord.children {
                switch wordChild.element!.name {
                case "phonetic":
                    word.phonetic = parseLanguageUnit(childWord["phonetic"], language: word.language)
                case "definition":
                    word.definition = parseTranslation(childWord["definition"], language: word.language, targetLanguage: targetLanguage)
                case "translation":
                    let languageUnit = parseLanguageUnit(wordChild, language: targetLanguage)
                    word.translations.append(languageUnit)
                case "synonym":
                    let synonym = parseLanguageUnit(wordChild, language: word.language)
                    word.synonyms.append(synonym)
                case "paradigm":
                    for paradigms in childWord["paradigm"].all {
                        let languageUnit = parseLanguageUnit(paradigms, language: word.language)
                        word.inflections.append(languageUnit)
                    }
                case "example":
                    let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                    word.examples.append(translation)
                case "compound":
                    let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                    word.compounds.append(translation)
                case "idiom":
                    let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                    word.idioms.append(translation)
                case "derivation":
                    let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                    word.derivations.append(translation)
                case "explanation":
                    word.explanation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                case "grammar":
                    word.grammar = parseLanguageUnit(wordChild, language: word.language)
                case "related":
                    if wordChild.element?.attributes["type"] == "antonym" {
                        let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage)
                        word.antonyms.append(translation)
                    } else {
                        print("NOT PARSED <related> type: \(wordChild.element?.attributes["type"])")
                    }
                default:
                    print("NOT PARSED : \(wordChild)")
                }
            }
            
            return word
        }
        
        func parseLanguageUnit(childTranslation: XMLIndexer, language: String) -> LanguageUnit {
            let value = childTranslation.element?.attributes["value"]
            let languageUnit = LanguageUnit()
            languageUnit.language = language;
            
            if let value = value {
                languageUnit.value = value;
            }
            
            return languageUnit;
        }
        
        func parseTranslation(childTranslation: XMLIndexer, language: String, targetLanguage: String) -> Translation {
            let translation = Translation()
            
            if let value = childTranslation.element?.attributes["value"] {
                translation.original = LanguageUnit();
                translation.original?.value = value;
                translation.original?.language = language;
            }
            
            if childTranslation["translation"].element != nil {
                translation.translation = parseLanguageUnit(childTranslation["translation"], language: targetLanguage);
            }
            
            
            return translation;
        }
        
        let xml = SWXMLHash.parse(xmlStr)
        
        parseDictionary(xml["dictionary"])
    }
}