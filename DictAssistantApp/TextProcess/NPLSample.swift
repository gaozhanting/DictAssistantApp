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

    func join(_ tokens: [String]) -> String {
        tokens.joined(separator: " ")
    }

    func lemma(_ text: String) -> [String] {
        var results: [String] = []
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
                    results.append(tag.rawValue)
                }
            } else {
                let word = String(text[tokenRange])
                print("    >>lemma with no tag: \(word)")
                results.append(word)
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
        let origin = withPrint("  sentence:", text)
        let tokens = withPrint("  tokenize word:", tokenize(origin, .word))
        let lemma = withPrint("  lemma:", lemma(join(tokens)))
        
        let lemmaedSentence = join(lemma)
        let name = withPrint("  name:", name(lemmaedSentence))
        
        let lc = withPrint("  lC:", lexicalClass(lemmaedSentence))
        var pResult: [String] = []
        for (index, (word, lexicalClass)) in lc.enumerated() {
            if index > 2 {
                let (ppreWord, ppreLexicalClass) = lc[index - 2]
                let (preWord, preLexicalClass) = lc[index - 1]
                if (ppreLexicalClass == "Verb" && preLexicalClass == "Adverb" && lexicalClass == "Particle") { // e.g: look forward to
                    let phrase = "\(ppreWord) \(preWord) \(word)"
                    pResult.append(phrase)
                }
            }
            
            if index > 1 {
                let (preWord, preLexicalClass) = lc[index - 1]
                if (preLexicalClass == "Verb" && lexicalClass == "Preposition") // e.g: take off
                    || (preLexicalClass == "Verb" && lexicalClass == "Particle") // e.g:
                    || (preLexicalClass == "Verb" && lexicalClass == "Adverb") // e.g: fall flat
                    || (preLexicalClass == "Noun" && lexicalClass == "Noun") // e.g: city state
                    || (preLexicalClass == "Adjective" && lexicalClass == "Noun") // e.g: open air
                    || (preLexicalClass == "Preposition" && lexicalClass == "Determiner") // e.g: after all
                    || (preLexicalClass == "Noun" && lexicalClass == "Preposition") // e.g: sort of
                    {
                    let phrase = "\(preWord) \(word)"
                    pResult.append(phrase)
                }
            }
        }
        let phrases = withPrint("  phrases:", pResult)
        
        let result = withPrint("  result:", lemma + name + phrases)
        return result
    }
    
    func process(_ texts: [String]) -> [String] {
        // for debug
        for text in texts {
            print(">>>>text from TR: \(text)")
        }
        
        // transform TR texts into multi sentences
        let originSentences = join(texts)
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
