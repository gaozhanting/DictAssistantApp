//
//  NPLSample.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/1.
//

import Foundation
import NaturalLanguage

struct NPLSample {
    func withPrint<T>(_ info: String, _ x: T) -> T {
        print(info)
        print(x)
        return x
    }

    func tokenize(_ text: String) -> [String] {
        var result: [String] = []
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            result.append(String(text[tokenRange]))
            return true
        }
        return result
    }

    func join(_ tokens: [String]) -> String {
        tokens.joined(separator: " ")
    }

    func lemma(_ text: String) -> [String] {
        var results: [String] = []
        let range = text.startIndex..<text.endIndex
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        tagger.setLanguage(.english, range: range)
        let options: NLTagger.Options = [
            .omitPunctuation,
            .omitWhitespace,
            .omitOther,
            .joinNames,
            .joinContractions
        ]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
            if let tag = tag {
                if !tag.rawValue.isEmpty {
                    results.append(tag.rawValue)
                }
            } else {
                
            }
            return true
        }
        return results
    }

    func name(_ text: String) -> [String] {
        var results: [String] = []
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                results.append(String(text[tokenRange]))
            }
            return true
        }
        return results
    }

    func lexicalClass(_ text: String) -> [(String, String)] {
        var result: [(String, String)] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                result.append((String(text[tokenRange]), tag.rawValue))
            }
            return true
        }
        return result
    }

    func processSingle(_ text: String) -> [String] {
        let origin = withPrint("origin:", text)
        let tokens = withPrint("tokenize:", tokenize(origin))
        let lemma = withPrint("lemma:", lemma(join(tokens)))
        let sentence = join(lemma)
        
        let name = withPrint("name:", name(sentence))
        
        let lc = withPrint("lC:", lexicalClass(sentence))
        var pResult: [String] = []
        for (index, (word, lexicalClass)) in lc.enumerated() {
            if lexicalClass == "Preposition" || lexicalClass == "Particle" {
                if index > 1 {
                    let (preWord, preLexicalClass) = lc[index-1]
                    if preLexicalClass == "Verb" {
                        let phrase = "\(preWord) \(word)"
                        pResult.append(phrase)
                    }
                }
            }
        }
        let phrases = withPrint("phrases:", pResult)
        
        let result = withPrint("result:", lemma + name + phrases)
        return result
    }
    
    func processMulti(_ texts: [String]) -> [String] {
        let result = processSingle(join(texts))
        let result2 = NSOrderedSet(array: result).map({ $0 as! String })
        return result2
    }
}

let nplSample = NPLSample()
