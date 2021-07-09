//
//  File.swift
//  
//
//  Created by Gao Cong on 2021/7/5.
//

import Foundation

public struct LemmaDB {
    public static func read(from filename: String) -> [String:String] {
        guard let path = Bundle.module.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            var dict: [String: String] = [:]
            let content = try String(contentsOf: path, encoding: String.Encoding.utf8)
            var lines = content.components(separatedBy: "\n")
            lines.removeLast() // last is empty string!
            for line in lines {
                let x = line.split(separator: ">", maxSplits: 1)
                let lemma = String(x[0])
                dict[lemma] = lemma // set stem word lemma it self
                let wordsX = x[1]
                let words = wordsX.split(separator: ",")
                for word in words {
                    dict[String(word)] = String(lemma)
                }
            }
            return dict
        }
        catch(_) {
            fatalError("Couldn't init from \(filename)")
        }
    }
}
