//
//  ProcessText.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

// to be refined: please use CharacterSet to do trim, filter, search etc

// e.g:
// ["I   love $you", "I lovee you  "] ->
// ["I", "you", "love", "lovee"] ->
// [S..Text(..)]
func transform(_ texts: [String]) -> [SingleClassifiedText] {
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
    
//    let uniqueCleanTexts = Array(Set(cleanTexts))
    let orderedNoDuplicates = NSOrderedSet(array: cleanTexts).map({ $0 as! String })

    return orderedNoDuplicates.map { text in
        // Notice: to be refined
        let existent = isExist(text)
        
        var knowable: Bool
        if existent {
            knowable = isKnowable(text)
        } else {
            knowable = false
        }
        
        var lookupable: Bool
        if !knowable {
            lookupable = isLookUpable(text)
        } else {
            lookupable = false
        }
                
        var translation: String
        if lookupable {
            translation = translate(text)
        } else {
            translation = "not found"
        }
        
        return SingleClassifiedText(
            text: text,
            existence: existent,
            knowable: knowable,
            lookupable: lookupable,
            translation: translation)
    }
}

let englishCharacterSet = genChars()
let englishCharacters = "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z - '"
let englishCharacters2 = "a b c d e f g h i j k l m n o p q r s t u v w x y z - '"
func genChars() -> Set<Character> {
    let characters = englishCharacters2
        .components(separatedBy: " ")
        .map { Character($0) }
    return Set(characters)
}
