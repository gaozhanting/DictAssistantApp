//
//  Utilities.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import Foundation
import AppKit.NSColor
import DataBases

func colorToData(_ color: NSColor) -> Data? {
    if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
        return data
    } else {
        return nil
    }
}

func dataToColor(_ data: Data) -> NSColor? {
    let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    let color = unarchivedData as NSColor?
    return color
}

func say(_ word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/say"
    var arguments = [String]();
    arguments.append(word)
    task.arguments = arguments
    task.launch()
}

func openDict(_ word: String) {
    let replaceSpaced = word.replacingOccurrences(of: " ", with: "-")
    let task = Process()
    task.launchPath = "/usr/bin/open"
    var arguments = [String]();
    arguments.append("dict://\(replaceSpaced)")
    task.arguments = arguments
    task.launch()
}

let validEnglishWordsCharacterSet = makeValidEnglishWordsCharacterSet()
let a_z = "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
func makeValidEnglishWordsCharacterSet() -> Set<Character> {
    var characters = a_z
        .components(separatedBy: " ")
        .map { Character($0) }
    characters.append(Character("-"))
    characters.append(Character("'"))
    characters.append(Character("."))
    characters.append(Character(" "))
    return Set(characters)
}

func makeFixedNoiseVocabulary() -> Set<String> {
    let oneLetterWords = a_z.components(separatedBy: " ").map { String($0) }
    
    var twoLetterWords: [String] = []
    for first in oneLetterWords {
        for second in oneLetterWords {
            twoLetterWords.append("\(first)\(second)")
        }
    }
    
    let extraNoiseWords = Vocabularies.read(from: "extra_fixed_noise_words.txt").components(separatedBy: "\n")
    
    let allNoiseWords = oneLetterWords + twoLetterWords + extraNoiseWords
    
    let oneLetterRealWords = Vocabularies.readToSet(from: "one_letter_real_words.txt")
    let twoLetterRealWords = Vocabularies.readToSet(from: "two_letter_real_words.txt")
    let result = Set(allNoiseWords).subtracting(oneLetterRealWords).subtracting(twoLetterRealWords)
    return result
}
