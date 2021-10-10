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

extension String {
    // I see hyphen also as a phrase
    var isPhrase: Bool {
        self.contains(" ") || self.contains("-")
    }
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

private let oneLetterRealWords = Set("a A i I".split(separator: Character(" ")).map { String($0) })
private let twoLetterRealWords = Set("ad am an as at ax be bi by do go he hi ho id if in is it me my no of oh ok OK on or ox so to up us uh um we tv TV".split(separator: Character(" ")).map { String($0) })

private func makeFixedNoiseVocabulary() -> Set<String> {
    let oneLetterWords = a_z.components(separatedBy: " ").map { String($0) }
    
    var twoLetterWords: [String] = []
    for first in oneLetterWords {
        for second in oneLetterWords {
            twoLetterWords.append("\(first)\(second)")
        }
    }
    
    let allNoiseWords = oneLetterWords + twoLetterWords
    
    let result = Set(allNoiseWords).subtracting(oneLetterRealWords).subtracting(twoLetterRealWords)
    return result
}

let logger = Logger()

func myPrint(_ str: String) {
    print(str) // or donothing
}

func timeElapsed(info: String, _ closure: () -> Void) {
    let startingPoint = Date()
    closure()
    logger.info("time elapsed of \(info): \(-startingPoint.timeIntervalSinceNow) seconds")
}

let systemDefaultMinimumTextHeight: Double = 0.03125

// first, why TR not cool here, it's my code fault (refer offical wwdc sample project)
// got this should not add it !
let fixedNoiseVocabulary = makeFixedNoiseVocabulary()

// use databases
let lemmaDB = LemmaDB.read(from: "lemma.en.txt") // take 0.38s
let oxford3000Vocabulary = Vocabularies.read(from: "oxford_3000.txt")
let wikiFrequencyWordsList = Vocabularies.read(from: "first_100_000_of_enwiki-20190320-words-frequency.txt")

