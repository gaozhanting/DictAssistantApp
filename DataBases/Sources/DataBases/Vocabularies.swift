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
//            return Set(content.components(separatedBy: "\n"))
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

public let phrasesDB = Vocabularies.readToSet(from: "phrases_and_idioms_extracted_from_brief_oxford_dict.txt")
/*
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


