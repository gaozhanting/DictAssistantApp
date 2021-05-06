//
//  SmallDict.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/6.
//

import Foundation

public let smallDictionary = readSmallDictionaryFile("small_dictionary.txt")

func readSmallDictionaryFile(_ filename: String) -> [String: String] {
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
