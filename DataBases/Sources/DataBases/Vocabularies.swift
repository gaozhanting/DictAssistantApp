//
//  SmallVocabulary.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

// change origin files in vscode using regex replace:
// find:([a-zA-Z-\.]+)(\s+)(.+)
// replace:$1

public struct Vocabularies {
    public static func read(from file: String) -> String {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil)
        else {
            fatalError("Couldn't find \(file) in main bundle.")
        }
        
        do {
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            return content
        }
        catch(_) {
            fatalError("Couldn't init from \(file)")
        }
    }
    
    public static func readToSet(from file: String) -> Set<String> {
        let string = Vocabularies.read(from: file)
        let idioms = string.split(separator: "\n").map { String($0) }
        return Set(idioms)
    }
}

public let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
public let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
public let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")
public let oxford3000Vocabulary = Vocabularies.read(from: "oxford_3000.txt")
public let wikiFrequencyWordsList = Vocabularies.read(from: "first_100_000_of_enwiki-20190320-words-frequency.txt")
