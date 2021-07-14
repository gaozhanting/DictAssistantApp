//
//  ProcessText.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases
import NaturalLanguage

struct TextProcess {
    // to be refined: please use CharacterSet to do trim, filter, search etc

    // texts: [String] -> words: [String]
    // e.g:
    // input: ["I Bookmarks  love you", "I lovee $you i.e. "]
    // middleput: ["i", "bookmarks", "love", "you", "lovee", "i.e."]
    // output: [S..Text(..)]
    static func extractWords(from texts: [String]) -> [String] {
        logger.info(">>texts")
//        myPrint(texts)
        
        let cleanTexts: [String] = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.components(separatedBy: .whitespaces) }
            .reduce([], +)
            .map { $0.lowercased() }
            .map { $0.filter { validEnglishWordsCharacterSet.contains($0) } }
            .filter { !$0.isEmpty }
        
        var all: String = ""
        for t in cleanTexts {
            all.append(t)
            all.append(" ")
        }
        
        logger.info(">>before lemm")
        myPrint(all)
        
        let b = lemm(of: all)
        logger.info(">>after lemm")
//        myPrint(b)

        let c = b.filter { !$0.isEmpty }
        logger.info(">>after lemm filter isEmpty")
//        myPrint(c)
        
        let orderedNoDuplicates = NSOrderedSet(array: c).map({ $0 as! String })
        
        return orderedNoDuplicates
    }

    static func lemm(of text: String) -> [String] {
        var results: [String] = []
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        let options: NLTagger.Options = [
            .omitPunctuation,
            .omitWhitespace,
            .omitOther,
            .joinNames,
            .joinContractions
        ]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
            if let tag = tag {
                if !tag.rawValue.isEmpty {
                    results.append(tag.rawValue)
                }
            } else {
                
            }
            return true
        }
        return results
    }
    
    static let validEnglishWordsCharacterSet = makeValidEnglishWordsCharacterSet()
    static let a_z = "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    static func makeValidEnglishWordsCharacterSet() -> Set<Character> {
        var characters = a_z
            .components(separatedBy: " ")
            .map { Character($0) }
        characters.append(Character("-"))
        characters.append(Character("'"))
        characters.append(Character("."))
        characters.append(Character(" "))
//        characters.append(Character(".")) // just very little words we don't care; . will harm lemma // currently not work with i.e. , e.g. , etc. , because . is used for punctuation most of the time!)
        return Set(characters)
    }

}
