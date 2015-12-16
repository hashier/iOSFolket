//
//  FolketXMLParser.swift
//  iOSFolket
//
//  Created by Christopher Loessl on 12/12/15.
//  Copyright © 2015 iOSFolket. All rights reserved.
//

import Foundation
import RealmSwift

enum FolketXMLParserError: ErrorType {
    case ParsingError
}

enum FolketXMLParserResultType {
    case Success(dictionary: WordDictionary)
    case Error(error: FolketXMLParserError)
}

class FolketXMLParser {
    var filePath: String
    
    init(withFilePath: String) {
        filePath = withFilePath
    }
    
    func parse(completion: (result: FolketXMLParserResultType) -> Void) -> Void {
        
        var xmlStr = try! String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        
        func parseDictionary(dictionaryElement: XMLElement) -> WordDictionary? {
            
            guard let sourceLanguage = dictionaryElement.attributes["source-language"], let targetLangage = dictionaryElement.attributes["target-language"] else {
                return nil
            }
            
            let dictionary = WordDictionary()
            
            dictionary.sourceLanguage = sourceLanguage
            dictionary.targetLanguage = targetLangage
            
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
            
            return dictionary;
        }
        
        func parseWord(wordElement: XMLElement, targetLanguage: String) -> Word? {
            
            guard let value = wordElement.attributes["value"], let language = wordElement.attributes["lang"] else {
                return nil
            }
            
            let wordClass = wordElement.attributes["class"]
            let word = Word()
            
            word.value = value
            word.language = language
            
            word.wordClass = wordClass
            
            for wordChild in wordElement.children {
                switch wordChild.name {
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
                case "variant":
                    if let languageUnit = parseLanguageUnit(wordChild, language: word.language) {
                        word.variants.append(languageUnit)
                    }
                case "paradigm":
                    for paradigms in wordChild.children {
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
                    if wordChild.attributes["type"] == "antonym" {
                        if let translation = parseTranslation(wordChild, language: word.language, targetLanguage: targetLanguage) {
                            word.antonyms.append(translation)
                        }
                    } else {
                        print("NOT PARSED <related> type: \(wordChild.attributes["type"])")
                    }
                default:
                    print("NOT PARSED : \(wordChild)")
                    break
                }
            }
            
            return word
        }
        
        func parseLanguageUnit(childLanguageUnit: XMLElement, language: String) -> LanguageUnit? {
            guard let value = childLanguageUnit.attributes["value"] else {
                return nil
            }
            
            let languageUnit = LanguageUnit()
            languageUnit.language = language;
            languageUnit.value = value;
            
            return languageUnit;
        }
        
        func parseTranslation(childTranslation: XMLElement, language: String, targetLanguage: String) -> Translation? {
            guard let value = childTranslation.attributes["value"]  else {
                return nil
            }
            
            let translation = Translation()
            
            let original = LanguageUnit();
            original.value = value;
            original.language = language;
            
            translation.original = original
            
            if let translationChild = childTranslation.children.first {
                translation.translation = parseLanguageUnit(translationChild, language: targetLanguage);
            }
            
            
            return translation;
        }
        

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            
            // Get the default Realm
            let realm = try! Realm()
            
            try! realm.write {
                realm.deleteAll()
            }
            
            var wordBatchCount = 0
            
            let xmlData = xmlStr.dataUsingEncoding(NSUTF8StringEncoding)!
            let parser = XMLParser()
            
            var currentDictionary:WordDictionary? = nil
            
            parser.parse(xmlData, didStartElement: { (xmlElement) -> Void in
                if xmlElement.name == "dictionary" {
                    
                    currentDictionary = parseDictionary(xmlElement)
                    
                    // We don't want put all the words in memory, we'll parse them as they come
                    xmlElement.preventAddingChildren = true
                }
                }, didEndElement:{ (xmlElement) -> Void in
                    
                    if xmlElement.name == "word" {
                        
                        // TODO remove hardcoded targetLanguage
                        if let dictionary = currentDictionary {
                            
                            autoreleasepool({ () -> () in
                                if wordBatchCount == 0 {
                                    realm.beginWrite()
                                }
                                
                                let word = parseWord(xmlElement, targetLanguage: dictionary.targetLanguage)
                                if let word = word {
                                    word.dictionary = currentDictionary
                                    realm.add(word);
                                }
                                
                                wordBatchCount++
                                
                                if wordBatchCount >= 1000 {
                                    wordBatchCount = 0
                                    
                                    try! realm.commitWrite()
                                }
                            })
                        }
                    }
            })
            
            if wordBatchCount > 0 {
                try! realm.commitWrite()
            }
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                if let dictionary = currentDictionary {
                    completion(result: .Success(dictionary: dictionary))
                } else {
                    completion(result: .Error(error: .ParsingError))
                }
            }
        }
        
    }
}

let rootElementName = "iOSFolket_Root_Element"

/// The implementation of NSXMLParserDelegate and where the parsing actually happens.
class XMLParser: NSObject, NSXMLParserDelegate {
    
    var root = XMLElement(name: rootElementName)
    var parentStack = [XMLElement]()
    
    var didStartElement:((xmlElement: XMLElement) -> Void)?
    var didEndElement:((xmlElement: XMLElement) -> Void)?
    
    override init() {
        super.init()
    }
    
    func parse(data: NSData, didStartElement:(xmlElement: XMLElement) -> Void, didEndElement:(xmlElement: XMLElement) -> Void) -> XMLElement {
        // clear any prior runs of parse... expected that this won't be necessary, but you never know
        parentStack.removeAll()
        
        self.didStartElement = didStartElement
        self.didEndElement = didEndElement
        
        parentStack.append(root)
        
        let parser = NSXMLParser(data: data)
        parser.shouldProcessNamespaces = false
        parser.delegate = self
        parser.parse()
        
        return root
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
        
        let element = parentStack.last!.addElement(elementName, withAttributes: attributeDict)
        parentStack.append(element)
        
        self.didStartElement?(xmlElement: element)
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        let current = parentStack.last!
        if current.text == nil {
            current.text = ""
        }
        
        current.text! += string
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let element = parentStack.popLast()
        
        self.didEndElement?(xmlElement: element!)
    }
}

/// Models an XML element, including name, text and attributes
public class XMLElement: CustomStringConvertible {
    
    public let name: String
    public var text: String?
    public var attributes = Dictionary<String, String>()
    
    public var preventAddingChildren = false
    
    var children = [XMLElement]()
    var count: Int = 0
    var index: Int
    
    init(name: String, index: Int = 0) {
        self.name = name
        self.index = index
    }
    
    func addElement(name: String, withAttributes attributes: Dictionary<String, String>) -> XMLElement {
        
        let element = XMLElement(name: name, index: count)
        count++
        
        // Preventing putting the whole xml in memory
        if preventAddingChildren == false {
            children.append(element)
        }
        
        element.attributes = attributes;
        
        return element
    }
    
    public var description: String {
        var attributesStringList = [String]()
        if !attributes.isEmpty {
            for (key, val) in attributes {
                attributesStringList.append("\(key)=\"\(val)\"")
            }
        }
        
        var attributesString = attributesStringList.joinWithSeparator(" ")
        if !attributesString.isEmpty {
            attributesString = " " + attributesString
        }
        
        if children.count > 0 {
            var xmlReturn = [String]()
            xmlReturn.append("<\(name)\(attributesString)>")
            for child in children {
                xmlReturn.append(child.description)
            }
            xmlReturn.append("</\(name)>")
            return xmlReturn.joinWithSeparator("\n")
        }
        
        if text != nil {
            return "<\(name)\(attributesString)>\(text!)</\(name)>"
        }
        else {
            return "<\(name)\(attributesString)/>"
        }
    }
}