//
//  SmallVocabulary.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

public let highSchoolVocabulary = HighSchoolVocabulary.read(filename: "high_school_vocabulary.txt")

struct HighSchoolVocabulary {
    static func read(filename: String) -> Set<String> {
        guard let url = Bundle.module.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            let content = try String(contentsOf: url, encoding: String.Encoding.utf8)
            return Set(content.components(separatedBy: "\n"))
        }
        catch(_) {
            fatalError("Couldn't init from \(filename)")
        }
    }
}
