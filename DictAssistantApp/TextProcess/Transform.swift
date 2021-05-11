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
        return highSchoolVocabulary.contains(word)
    }

    static func isLookUpable(_ word: String) -> Bool {
        return smallDictionary[word] != nil
    }

    static func translate(_ word: String) -> String {
        return smallDictionary[word]!
    }

    // e.g:
    // ["I   love $you", "I lovee you  "] ->
    // ["I", "you", "love", "lovee"] ->
    // [S..Text(..)]
    static func classify(_ texts: [String]) -> [SingleClassifiedText] {
        let cleanTexts: [String] =
            texts.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                 .map { $0.components(separatedBy: .whitespaces) }
                 .map { texts in
                    texts.filter { text in
                        !text.isEmpty
                    }
                 }
                 .reduce([], +)
                 .map { $0.filter { englishCharacterSet.contains($0) } }
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

    static let englishCharacterSet = genChars()
    static let englishCharacters = "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z - '"
    static let englishCharacters2 = "a b c d e f g h i j k l m n o p q r s t u v w x y z - '"
    static func genChars() -> Set<Character> {
        let characters = englishCharacters2
            .components(separatedBy: " ")
            .map { Character($0) }
        return Set(characters)
    }

}
