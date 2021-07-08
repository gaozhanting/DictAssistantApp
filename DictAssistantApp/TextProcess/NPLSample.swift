//
//  NPLSample.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/1.
//

import Foundation
import NaturalLanguage
import DataBases

struct NPLSample {
    func tokenize(_ sentence: String, _ tokenUnit: NLTokenUnit) -> [String] {
        var result: [String] = []
        let tokenizer = NLTokenizer(unit: tokenUnit)
        tokenizer.string = sentence
        tokenizer.enumerateTokens(in: tokenizer.string!.startIndex..<tokenizer.string!.endIndex) { tokenRange, _ in
            let token = String(sentence[tokenRange])
            result.append(token)
            return true
        }
        return result
    }
    
    struct Word {
        let token: String
        let lemma: String
    }

    func lemma(_ sentence: String) -> [Word] {
        var results: [Word] = []
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = sentence
        let range = tagger.string!.startIndex..<tagger.string!.endIndex
        tagger.setLanguage(.english, range: range)
        let options: NLTagger.Options = [
            .omitWhitespace,
            .omitOther
        ]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
            let token = String(sentence[tokenRange])

            if let tag = tag {
                if !tag.rawValue.isEmpty {
                    let lemma = tag.rawValue
                    results.append(Word(token: token, lemma: lemma))
                } else {
                    print("    >>lemma from apple, but raw value of tag is empty!!") // seems to be impossible
                    results.append(Word(token: token, lemma: "???")) // placeholder to keep align of token and lemma
                }
                return true
            }
            
            if let lemma = lemmaDB[token.lowercased()] { // because our lemmadDB is all lowercased words
                print("    >>lemma >>>->>->>found-from-db: \(token): \(lemma)")
                results.append(Word(token: token, lemma: lemma))
            } else {
                print("    >>lemma not-found-even-from-db: \(token)")
                results.append(Word(token: token, lemma: "???")) // placeholder to keep align of token and lemma
            }
            return true
        }
        return results
    }

    func name(_ sentence: String) -> [Int: String] {
        var results: [Int: String] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = sentence
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: tagger.string!.startIndex..<tagger.string!.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            let token = String(sentence[tokenRange])

            if let tag = tag, tags.contains(tag) {
                let name = token
//                let x = name.split(separator: " ")
//                let lastTokenOfName = String(x.last!)
                let untilLastText = sentence[sentence.startIndex..<tokenRange.upperBound]
                let index = untilLastText.filter { char in
                    char == " "
                }.count
                results[index] = name // for mix order
            }
            return true
        }
        return results
    }

    func lexicalClass(_ sentence: String) -> [(String, String)] {
        var result: [(String, String)] = []
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = sentence
        let options: NLTagger.Options = [.omitWhitespace]
        tagger.enumerateTags(in: tagger.string!.startIndex..<tagger.string!.endIndex, unit: .word, scheme: .lexicalClass, options: options) { tag, tokenRange in
            let token = String(sentence[tokenRange])

            if let tag = tag {
                result.append((token, tag.rawValue)) // this maybe Number; e.g: 16
            } else {
                print("    >>lexicalClass with no lexicalClass!!") // this should impossible
            }
            return true
        }
        return result
    }
    
    // bug: (may lose phrase because the key is the single token; the key should be the last phrase|name token index of the sentence)
    // in: "in the same way"
    // in: "in the thick of"
    func phrase(_ sentence: String) -> [Int: String] {
        let lc = lexicalClass(sentence)
        var result: [Int: String] = [:]
        for (index, (word, lexicalClass)) in lc.enumerated() {
            if index >= 1 {
                let (preWord, preLexicalClass) = lc[index - 1]
                let phrase = "\(preWord) \(word)"
                if idiomsDB.contains(phrase) {
                    result[index] = phrase
                }
                else { // todo: use no lexicalClass to detect phrase or idioms, but use database from truly Dictionary
                    if (preLexicalClass == "Verb" && lexicalClass == "Preposition") // e.g: take off
                        || (preLexicalClass == "Verb" && lexicalClass == "Particle") // e.g:
                        || (preLexicalClass == "Verb" && lexicalClass == "Adverb") // e.g: fall flat
                        || (preLexicalClass == "Noun" && lexicalClass == "Noun") // e.g: city state // Many noise word are recognized as Noun!!
                        || (preLexicalClass == "Adjective" && lexicalClass == "Noun") // e.g: open air
                        || (preLexicalClass == "Preposition" && lexicalClass == "Determiner") // e.g: after all
                        || (preLexicalClass == "Noun" && lexicalClass == "Preposition") // e.g: sort of
                    {
                        result[index] = phrase
                    }
                }
            }
            
            if index >= 2 {
                let (ppreWord, ppreLexicalClass) = lc[index - 2]
                let (preWord, preLexicalClass) = lc[index - 1]
                let phrase = "\(ppreWord) \(preWord) \(word)"
                if idiomsDB.contains(phrase) {
                    result[index] = phrase
                }
                else {
                    if ppreLexicalClass == "Verb" && preLexicalClass == "Adverb" && lexicalClass == "Particle" { // e.g: look forward to
                        result[index] = phrase
                    }
                }
            }
        }
        return result
    }

    func processSingle(_ text: String) -> [String] {
        let origin = text
        
        let tokens = tokenize(origin, .word)
        let sentence = tokens.joined(separator: " ")
        print("sentence:\(sentence)")
        let originNames = name(sentence)
        print("originNames:\(originNames)")
        let originPhrases = phrase(sentence)
        print("originPhrases:\(originPhrases)")

        let lemmas = lemma(sentence)
        
        let lemmaedSentence = lemmas.map{ $0.lemma }.joined(separator: " ")
        print("lemmaedSentence:\(lemmaedSentence)")
                
        let lemmaedNames = name(lemmaedSentence)
        print("lemmaedNames:\(lemmaedNames)")
        
        let lemmaedPhrases = phrase(lemmaedSentence)
        print("lemmaedPhrases:\(lemmaedPhrases)")
        
        var result: [String] = []
        for (index, word) in lemmas.enumerated() {
            result.append(word.lemma)
            
            if let name = originNames[index] {  // originNames first
                if name.lowercased() != word.lemma.lowercased() {
                    result.append(name)
                }
            }
            else {
                if let name = lemmaedNames[index] {
                    if name.lowercased() != word.lemma.lowercased() {
                        result.append(name)
                    }
                }
            }
            
            if let phrase = originPhrases[index] { // originPhrase first
                let originName = originNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                if (phrase.lowercased() != originName.lowercased()) && (phrase.lowercased() != lemmaedName.lowercased()) { // name first, de-duplicate
                    result.append(phrase)
                }
            }
            
            if let phrase = lemmaedPhrases[index] { // lemmaedPhrase still need to add, here not like name
                let originName = originNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                let originPhrase = originPhrases[index] ?? ""
                if (phrase.lowercased() != originName.lowercased()) && (phrase.lowercased() != lemmaedName.lowercased()) && (phrase.lowercased() != originPhrase.lowercased()) { // name first, de-duplicate
                    result.append(phrase)
                }
            }
            
        }
        return result
    }
    
    func process(_ texts: [String]) -> [String] {
        // for debug
        for text in texts {
            print(">>>>text from TR: \(text)")
        }
        
        // transform TR texts into multi sentences
        let originSentences = texts.joined(separator: " ")
        let sentences = tokenize(originSentences, .sentence)
        
        // for every sentence
        var results: [String] = []
        print(">>>>NPL process:")
        for sentence in sentences {
            let result = processSingle(sentence)
            print(">>>>sentence: \(sentence)")
            print(">>>>result: \(result)")
            results += result
        }
        
        return results
    }
}

let nplSample = NPLSample()
