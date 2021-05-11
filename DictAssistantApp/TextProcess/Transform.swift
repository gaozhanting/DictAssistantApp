//
//  ProcessText.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation
import DataBases

struct Transform {
    // to be refined: please use CharacterSet to do trim, filter, search etc

    // lookup all English words
    // need an all English vocabulary
    static func isExist(_ word: String) -> Bool {
        return true
    }

    static func isKnowable(_ word: String) -> Bool {
        if highSchoolVocabulary.contains(word) {
            return true
        }
        if cet4Vocabulary.contains(word) {
            return true
        }
        if cet6Vocabulary.contains(word) {
            return true
        }
        return false
    }

    static func isLookUpable(_ word: String) -> Bool {
        return smallDictionary[word] != nil
    }

    static func translate(_ word: String) -> String {
        return smallDictionary[word]!
    }

    // e.g:
    // input: ["I Bookmarks  love you", "I lovee $you i.e. "]
    // middleput: ["i", "bookmarks", "love", "you", "lovee", "i.e."]
    // output: [S..Text(..)]
    static func classify(_ texts: [String]) -> [SingleClassifiedText] {
        let cleanTexts: [String] = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { $0.components(separatedBy: .whitespaces) }
            .reduce([], +)
            .map { $0.lowercased() }
            .map { $0.filter { invalidEnglishWordsCharacterSet.contains($0) } }
            .filter { !$0.isEmpty }
            .filter { !isKnowable($0) }
        
        let orderedNoDuplicates = NSOrderedSet(array: cleanTexts).map({ $0 as! String })

        return orderedNoDuplicates.map { word in
            let lookupable: Bool = isLookUpable(word)
            var translation: String {
                if lookupable {
                    return translate(word)
                } else {
                    return ""
                }
            }
            
            return SingleClassifiedText(
                text: word,
                existence: true,
                knowable: false,
                lookupable: lookupable,
                translation: translation)
        }
    }

    static let invalidEnglishWordsCharacterSet = makeInvalidEnglishWordsCharacterSet()
    static let a_z = "a b c d e f g h i j k l m n o p q r s t u v w x y z"
    static func makeInvalidEnglishWordsCharacterSet() -> Set<Character> {
        var characters = a_z
            .components(separatedBy: " ")
            .map { Character($0) }
        characters.append(Character("-"))
        characters.append(Character("'"))
        characters.append(Character("."))
        return Set(characters)
    }

}
