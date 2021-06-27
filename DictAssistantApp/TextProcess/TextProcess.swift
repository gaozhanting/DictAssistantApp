//
//  ProcessText.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases
import NaturalLanguage

let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

struct TextProcess {
    // to be refined: please use CharacterSet to do trim, filter, search etc

    // texts: [String] -> words: [String]
    // e.g:
    // input: ["I Bookmarks  love you", "I lovee $you i.e. "]
    // middleput: ["i", "bookmarks", "love", "you", "lovee", "i.e."]
    // output: [S..Text(..)]
    static func extractWords(from texts: [String]) -> [String] {
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
        print(all)
        
        let b = lemm(of: all)
        logger.info(">>after lemm")
        print(b)

        let c = b.filter { !$0.isEmpty }
        print(c)
        
        let orderedNoDuplicates = NSOrderedSet(array: c).map({ $0 as! String })
        
        return orderedNoDuplicates
    }

    static func lemm(of text: String) -> [String] {
        var results: [String] = []
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
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
        characters.append(Character(".")) // currently not work with i.e. , e.g. , etc. , because . is used for punctuation most of the time!)
        return Set(characters)
    }

}
