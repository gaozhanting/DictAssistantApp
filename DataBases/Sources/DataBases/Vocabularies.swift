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
    
    public static func readToArray(from file: String) -> [String] {
        let text = Vocabularies.read(from: file)
        var lines = text.components(separatedBy: .newlines)
        lines.removeLast()
        return lines
    }
    
    public static func readToSet(from file: String) -> Set<String> {
        return Set(readToArray(from: file))
    }
}
