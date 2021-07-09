////
////  File.swift
////  
////
////  Created by Gao Cong on 2021/7/9.
////
//
//import Foundation
//
//struct PhraseFromDictionary {
//    static func read(from filename: String) -> Set<String> {
//        guard let path = Bundle.module.url(forResource: filename, withExtension: nil)
//        else {
//            fatalError("Couldn't find \(filename) in main bundle.")
//        }
//        
//        do {
//            var set: Set<String> = Set.init()
//            let content = try String(contentsOf: path, encoding: String.Encoding.utf16LittleEndian)
//            var lines = content.components(separatedBy: "\n")
//            lines.removeLast() // last is empty string!
//            for line in lines {
//                let parts = line.split(separator: "\t")
////                if line.contains("stand agains") {
////                    print(line)
////                }
////                if parts.count == 1 { // not \t
////                    print(parts)
////                }
//                let word = String(parts[0])
//                    .trimmingCharacters(in: .whitespacesAndNewlines)
////                let others = String(parts[1])
////                    .replacingOccurrences(of: "\\n", with: "")
//                if word.contains(" ") { // not a single word, that is phrase or idioms
//                    set.insert(word)
//                }
//            }
//            return set // set.count is 30828; dict count is 142286|142250(lost some not \t); that is 21.6%
//        }
//        catch(_) {
//            fatalError("Couldn't init from \(filename)")
//        }
//    }
//}
//
//public let phraseDB = PhraseFromDictionary.read(from: "phrases_and_idioms_extracted_from_brief_oxford_dict.txt")
