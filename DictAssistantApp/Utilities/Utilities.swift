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

let logger = Logger(subsystem: "com.gaozhanting.DictAssistantApp", category: "main")

func timeElapsed(info: String, _ closure: () -> Void) {
    let startingPoint = Date()
    closure()
    logger.info("time elapsed of \(info, privacy: .public): \(-startingPoint.timeIntervalSinceNow, privacy: .public) seconds")
}

let systemDefaultMinimumTextHeight: Double = 0.03125

// use databases

// first, why TR not cool here, it's my code fault (refer offical wwdc sample project)
// got this should not add it !
let noisesDB = Vocabularies.readToArray(from: "noises.txt")

let lemmaDB = LemmaDB.read(from: "lemma.en.txt") // take 0.38s

let phrasesDB = Vocabularies.readToArray(from: "phrases.txt")

let oxford3000Vocabulary = Vocabularies.read(from: "oxford_3000.txt")
let wikiFrequencyWordsList = Vocabularies.read(from: "first_100_000_of_enwiki-20190320-words-frequency.txt")

let zhsEntriesDB = Vocabularies.readToArray(from: "lazyworm_ec.csv")
let japEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Japanese.csv")
let korEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Korean.csv")
let gerEntriesDB = Vocabularies.readToArray(from: "Babylon_English_German.csv")
let freEntriesDB = Vocabularies.readToArray(from: "Babylon_English_French.csv")
let spaEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Spanish.csv")
let porEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Portuguese.csv")
let itaEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Italian.csv")
let dutEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Dutch.csv")
let sweEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Swedish.csv")
let rusEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Russian.csv")
let greEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Greek.csv")
let turEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Turkish.csv")
let hebEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Hebrew.csv")
let araEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Arabic.csv")
let hinEntriesDB = Vocabularies.readToArray(from: "Hindi.csv")
