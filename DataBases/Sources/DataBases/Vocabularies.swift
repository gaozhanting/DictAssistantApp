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

public let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
public let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
public let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

struct Vocabularies {
    static func read(from file: String) -> Set<String> {
        guard let url = Bundle.module.url(forResource: file, withExtension: nil)
        else {
            fatalError("Couldn't find \(file) in main bundle.")
        }
        
        do {
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            return Set(content.components(separatedBy: "\n"))
        }
        catch(_) {
            fatalError("Couldn't init from \(file)")
        }
    }
}
