//
//  File.swift
//  
//
//  Created by Gao Cong on 2021/11/25.
//

import Foundation



public struct Dictionaries {
    public static func tryPrint(from filename: String) -> Void {
        guard let path = Bundle.module.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            let content = try String(contentsOf: path, encoding: String.Encoding.utf8)
            
            let pattern = """
"(?<word>.+?)","(?<trans>(.|\n)+?)"
"""
            let regex = try NSRegularExpression(pattern: pattern)
            let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
            for match in matches {
                guard #available(macOS 10.13, *) else { return }
                guard let wordRange = Range(match.range(withName: "word"), in: content) else { return }
                guard let transRange = Range(match.range(withName: "trans"), in: content) else { return }
                
                let word = String(content[wordRange])
                
                let trans = String(content[transRange])
                let transM = trans.replacingOccurrences(of: "\n", with: "")
                
                print("\(word),\(transM)")
            }
        }
        catch(_) {
            fatalError("fatalError in tryPrint")
        }
    }
    
    
    
    public static func readSmallDict(from filename: String) -> [String: String] {
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
                let parts = line.split(separator: " ")
                let word = String(parts[0])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let others = String(parts[1])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                dict[word] = others
//                let res = groups(line, for: "(\\w+)(\\s+)(.+)")
//                let word = res[0][1]
//                let zhTranslation = res[0][3]
//                dict[word] = zhTranslation
            }
            return dict
        }
        catch(_) {
            fatalError("Couldn't init from \(filename)")
        }
    }
    
    public static func readOxfordDict(from filename: String) -> [String: String] {
        guard let path = Bundle.module.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            var dict: [String: String] = [:]
            let content = try String(contentsOf: path, encoding: String.Encoding.utf16LittleEndian)
            var lines = content.components(separatedBy: "\n")
            lines.removeLast() // last is empty string!
            for line in lines {
                let parts = line.split(separator: "\t")
                let word = String(parts[0])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let others = String(parts[1])
                    .replacingOccurrences(of: "\\n", with: "")
                dict[word] = others
            }
            return dict
        }
        catch(_) {
            fatalError("Couldn't init from \(filename)")
        }
    }

    // No use of this; only split line string is OK!
//    static func groups(_ text: String, for regexPattern: String) -> [[String]] {
//        do {
//            let regex = try NSRegularExpression(pattern: regexPattern)
//            let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
//            return matches.map { match in
//                (0 ..< match.numberOfRanges).map {
//                    let rangeBounds = match.range(at: $0)
//                    guard let range = Range(rangeBounds, in: text) else {
//                        return ""
//                    }
//                    return String(text[range])
//                }
//            }
//        } catch let error {
//            logger.info("invalid regex: \(error.localizedDescription)")
//            return []
//        }
//    }
}
