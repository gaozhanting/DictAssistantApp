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

let logger = Logger()
func myPrint(_ str: String) {
    print(str) // or donothing
}

let systemDefaultMinimumTextHeight: Double = 0.03125

// global big constants
/*
 count is 30828; dict count is 142286|142250(lost some not \t); that is 21.6%
 
 all contains belows
 2 words: all 30828
 3 words: 10067
 4 words: 4082
 // ignores belows when do phrase detect programming
 5 words: 1443
 6 words: 434
 7 words: 83
 8 words: 9
 9 words: 2
 10 words: 1
 */
var phrasesDB: Set<String> = Set.init()
var lemmaDB: [String: String] = [:]

// first, why TR not cool here, it's my code fault (refer offical wwdc sample project)
// got this should not add it !
var fixedNoiseVocabulary: Set<String> = Set.init()


let defaultFontSizeOfLandscape = 30.0
let defaultFontSizeOfPortrait = 18.0

// UserDefault keys:
let TRTextRecognitionLevelKey = "TRTextRecognitionLevelKey"
let TRMinimumTextHeightKey = "TRMinimumTextHeightKey"

let IsShowPhrasesKey = "IsShowPhrasesKey"
let IsAddLineBreakKey = "IsAddLineBreakKey"
let IsShowCurrentKnownKey = "IsShowCurrentKnownKey"
let FontRateKey = "FontRateKey"
