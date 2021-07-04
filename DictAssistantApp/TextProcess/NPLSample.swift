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
        print("\(info): \(x)")
        return x
    }

    func tokenize(_ text: String, _ tokenUnit: NLTokenUnit) -> [String] {
        var result: [String] = []
        let tokenizer = NLTokenizer(unit: tokenUnit)
        tokenizer.string = text
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
            result.append(String(text[tokenRange]))
            return true
        }
        return result
    }

    func lemma(_ text: String) -> [(Range<String.Index>, String)] {
        var results: [(Range<String.Index>, String)] = []
        let range = text.startIndex..<text.endIndex
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
//        tagger.setLanguage(.english, range: range)
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
                    results.append((tokenRange, (tag.rawValue)))
                }
            } else {
                let word = String(text[tokenRange])
                print("    >>lemma with no tag: \(word)")
                results.append((tokenRange, word))
            }
            return true
        }
        return results
    }

    func name(_ text: String) -> [Range<String.Index>:String] {
        var results: [Range<String.Index>:String] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
//                results.append(String(text[tokenRange]))
                results[tokenRange] = String(text[tokenRange])
            }
            return true
        }
        return results
    }

    func lexicalClass(_ text: String) -> [(Range<String.Index>, String, String)] {
        var result: [(Range<String.Index>, String, String)] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            if let tag = tag {
                result.append((tokenRange, String(text[tokenRange]), tag.rawValue))
            }
            return true
        }
        return result
    }
    
    func phrase(_ sentence: String) -> [Range<String.Index> : String] {
        let lc = withPrint("  lC:", lexicalClass(sentence))
        var pResult: [Range<String.Index>:String] = [:]
        for (index, (_, word, lexicalClass)) in lc.enumerated() {
            if index > 2 {
                let (ppTokenRange, ppreWord, ppreLexicalClass) = lc[index - 2]
                let (_, preWord, preLexicalClass) = lc[index - 1]
                if (ppreLexicalClass == "Verb" && preLexicalClass == "Adverb" && lexicalClass == "Particle") { // e.g: look forward to
                    let phrase = "\(ppreWord) \(preWord) \(word)"
                    pResult[ppTokenRange] = phrase
                }
            }
            
            if index > 1 {
                let (pTokenRange, preWord, preLexicalClass) = lc[index - 1]
                if (preLexicalClass == "Verb" && lexicalClass == "Preposition") // e.g: take off
                    || (preLexicalClass == "Verb" && lexicalClass == "Particle") // e.g:
                    || (preLexicalClass == "Verb" && lexicalClass == "Adverb") // e.g: fall flat
                    || (preLexicalClass == "Noun" && lexicalClass == "Noun") // e.g: city state
                    || (preLexicalClass == "Adjective" && lexicalClass == "Noun") // e.g: open air
                    || (preLexicalClass == "Preposition" && lexicalClass == "Determiner") // e.g: after all
                    || (preLexicalClass == "Noun" && lexicalClass == "Preposition") // e.g: sort of
                    {
                    let phrase = "\(preWord) \(word)"
                    pResult[pTokenRange] = phrase
                }
            }
        }
        return pResult
    }

    func processSingle(_ text: String) -> [String] {
        let origin = withPrint("  sentence:", text)
        
        let tokens = withPrint("  tokenize word:", tokenize(origin, .word))
        let sentence = tokens.joined(separator: " ")
        let originName = withPrint("  originName:", name(sentence))
        let originPhrases = withPrint("  originPhrases:", phrase(sentence))

        let lemma = withPrint("  lemma:", lemma(sentence))
        let lemmaedSentence = lemma.map{ $0.1 }.joined(separator: " ")
        let lemmaedName = withPrint("  lemmaedName:", name(lemmaedSentence))
        let lemmaedPhrases = withPrint("  lemmaedPhrases:", phrase(lemmaedSentence))
        
        var result: [String] = []
        for (tokenRange, token) in lemma {
            result.append(token)
            if let nameToken = originName[tokenRange] { // range may diff little?!!!
                result.append(nameToken)
            }
            if let nameToken = lemmaedName[tokenRange] {
                result.append(nameToken)
            }
            if let phraseToken = originPhrases[tokenRange] {
                result.append(phraseToken)
            }
            if let phraseToken = lemmaedPhrases[tokenRange] {
                result.append(phraseToken)
            }
        }
        
        let result2 = withPrint("  result:", result)
        return result2
    }
    
    func process(_ texts: [String]) -> [String] {
        // for debug
        for text in texts {
            print(">>>>text from TR: \(text)")
        }
        
        // transform TR texts into multi sentences
        let originSentences = texts.joined(separator: " ")
        let sentences = withPrint("  tokenize sentence:", tokenize(originSentences, .sentence))
        
        // for every sentence
        var results: [String] = []
        print(">>>>NPL process:")
        for sentence in sentences {
            let result = processSingle(sentence)
            print(">>>>sentence: \(sentence)")
            print(">>>>result: \(result)")
            results += result
        }

        // de duplicate
        let deDuplicated = NSOrderedSet(array: results).map({ $0 as! String })
        return deDuplicated
    }
    
}

let nplSample = NPLSample()
