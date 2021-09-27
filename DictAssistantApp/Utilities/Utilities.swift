//
//  Utilities.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import Foundation
import AppKit.NSColor
import DataBases
import os

func isAPhrase(_ word: String) -> Bool {
    word.contains(" ")
}

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

//func fontToData(_ font: NSFont) -> Data? {
//    if let data = try? NSKeyedArchiver.archivedData(withRootObject: font, requiringSecureCoding: false) {
//        return data
//    } else {
//        return nil
//    }
//}
//
//func dataToFont(_ data: Data) -> NSFont? {
//    let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSFont.self, from: data)
//    let font = unarchivedData as NSFont?
//    return font
//}

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
fileprivate let a_z = "a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
fileprivate func makeValidEnglishWordsCharacterSet() -> Set<Character> {
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
    
    let extraNoiseWords = Vocabularies.read(from: "extra_fixed_noise_words.txt").components(separatedBy: .newlines)
    
    let allNoiseWords = oneLetterWords + twoLetterWords + extraNoiseWords
    
    let oneLetterRealWords = Vocabularies.readToSet(from: "one_letter_real_words.txt")
    let twoLetterRealWords = Vocabularies.readToSet(from: "two_letter_real_words.txt")
    let result = Set(allNoiseWords).subtracting(oneLetterRealWords).subtracting(twoLetterRealWords)
    return result
}

let logger = Logger()
func myPrint(_ str: String) {
    print(str) // or donothing
}

func timeElapsed(info: String, with closure: () -> Void) {
    let startingPoint = Date()
    closure()
    logger.info(">>time elapsed of \(info): \(-startingPoint.timeIntervalSinceNow) seconds")
}

let systemDefaultMinimumTextHeight: Double = 0.03125

// global big constants
/*
 count is 366502
 
 all contains belows
 2 words: 262321 71%
 3 words: 74687 20%
 4 words: 21620 5%
 5 words: 6898 2%
 // ignores >5 when do phrase detect programming
 */
let phrasesDB = Vocabularies.readToSet(from: "phrases_from_ecdict.txt") // take 2.28s, too long

let lemmaDB = LemmaDB.read(from: "lemma.en.txt") // take 0.38s

// first, why TR not cool here, it's my code fault (refer offical wwdc sample project)
// got this should not add it !
let fixedNoiseVocabulary = makeFixedNoiseVocabulary()
