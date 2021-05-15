//
//  ProcessText.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases
import NaturalLanguage

struct Transform {
    // to be refined: please use CharacterSet to do trim, filter, search etc

    // lookup all English words
    // need an all English vocabulary
    static func isExist(_ word: String) -> Bool {
        return true
    }

    static func isKnowable(_ word: String) -> Bool {
        if manuallyBasicVocabulary.contains(word) {
            return true
        }
        if highSchoolVocabulary.contains(word) {
            return true
        }
        if cet4Vocabulary.contains(word) {
            return true
        }
//        if cet6Vocabulary.contains(word) {
//            return true
//        }
        return false
    }

    static func translate(_ word: String) -> (String?, Bool) {
//        if let translation = oxfordDictionary[word] {
//            return (translation, false)
//        }
        if let translation = DictionaryServices.define(word) {
            return (translation, true)
        }
        return (nil, false)
    }

    // e.g:
    // input: ["I Bookmarks  love you", "I lovee $you i.e. "]
    // middleput: ["i", "bookmarks", "love", "you", "lovee", "i.e."]
    // output: [S..Text(..)]
    static func classify(_ texts: [String]) -> [Word] {
        let cleanTexts: [String] = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.components(separatedBy: .whitespaces) }
            .reduce([], +)
            .map { $0.lowercased() }
            .map { $0.filter { invalidEnglishWordsCharacterSet.contains($0) } }
            .filter { !$0.isEmpty }
            .filter { !isKnowable($0) }
        
        var all: String = ""
        for t in cleanTexts {
            all.append(t)
            all.append(" ")
        }
        
        print(">>before lemma")
        print(all)
        
        let b = lemmaWithOneWordCaseFixing(of: all)
        print(">>after lemma")
        print(b)

        let c = b.filter { !$0.isEmpty }
        let d = c.filter { !isKnowable($0) }
        print(">>after filter knowable again")
        print(d)
        
        let orderedNoDuplicates = NSOrderedSet(array: d).map({ $0 as! String })

        return orderedNoDuplicates.map { word in
            let (translation, isTranslationFromDictionaryServices) = translate(word)
            return Word(
                text: word,
                existence: true,
                knowable: false,
                translation: translation,
                isTranslationFromDictionaryServices: isTranslationFromDictionaryServices)
        }
    }
    
    // Because lemma always return null when meeting only one word; add the then delete the
    static func lemmaWithOneWordCaseFixing(of text: String) -> [String] {
        let whiteSpace = Character(" ")
        if !text.contains(whiteSpace) {
            let results = lemma(of: "the \(text)")
            if let lemmaOfText = results.last {
                return [lemmaOfText]
            } else {
                return []
            }
        } else {
            return lemma(of: text)
        }
    }
    
    static func lemma(of text: String) -> [String] {
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
    
    static let invalidEnglishWordsCharacterSet = makeInvalidEnglishWordsCharacterSet()
    static let a_z = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
    static func makeInvalidEnglishWordsCharacterSet() -> Set<Character> {
        var characters = a_z
            .components(separatedBy: " ")
            .map { Character($0) }
        characters.append(Character("-"))
        characters.append(Character("'"))
//        characters.append(Character(".")) // currently not work with i.e. , e.g. , etc. , because . is used for punctuation most of the time!)
        return Set(characters)
    }

}
