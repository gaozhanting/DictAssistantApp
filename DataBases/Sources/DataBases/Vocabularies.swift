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

let idioms2DB = Vocabularies.readToSet(from: "idioms_of_two_words.txt")
let idioms3DB = Vocabularies.readToSet(from: "idioms_of_three_words.txt")
let idioms4DB = Vocabularies.readToSet(from: "idioms_of_four_words.txt")

public let idiomsDB = idioms2DB.union(idioms3DB).union(idioms4DB)

