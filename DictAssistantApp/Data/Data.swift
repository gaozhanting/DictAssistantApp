//
//  filter.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/3.
//

import Foundation

let basicDict = readDict("en-zh.txt")
let basicWords = readBasic("en_basic.txt")

func readBasic(_ filename: String) -> Set<String> {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        return Set(content.components(separatedBy: "\n"))
    }
    catch(_) {
        fatalError("Couldn't init from \(filename)")
    }
}

func genChars() -> Set<Character> {
    let characters = "a b c d e f g h i j k l m n o p q r s t u v w x y z -"
        .components(separatedBy: " ")
        .map { Character($0) }
    return Set(characters)
}

func groups(_ text: String, for regexPattern: String) -> [[String]] {
    do {
        let regex = try NSRegularExpression(pattern: regexPattern)
        let matches = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return matches.map { match in
            return (0..<match.numberOfRanges).map {
                let rangeBounds = match.range(at: $0)
                guard let range = Range(rangeBounds, in: text) else {
                    return ""
                }
                return String(text[range])
            }
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}

func readDict(_ filename: String) -> [String: String] {
    guard let path = Bundle.main.path(forResource: filename, ofType: nil)
    else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        var dict: [String: String] = [:]
        let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
        var lines = content.components(separatedBy: "\n")
        lines.removeLast() // last is empty string!
        for line in lines {
            let res = groups(line, for: "(\\w+)(\\s+)(.+)")
            let word = res[0][1]
            let zhTranslation = res[0][3]
            dict[word] = zhTranslation
        }
        return dict
    }
    catch(_) {
        fatalError("Couldn't init from \(filename)")
    }
}
