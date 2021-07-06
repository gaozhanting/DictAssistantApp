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
    func withPrint<T>(_ info: String, _ x: T) -> T {
//        print("\(info): \(x)")
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
    
    struct Word {
        let token: String
        let lemma: String
    }

    func lemma(_ text: String) -> [Word] {
        var results: [Word] = []
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
                    results.append(Word(token: String(text[tokenRange]), lemma: tag.rawValue))
                }
            } else {
                let word = String(text[tokenRange])
                print("    >>lemma with no tag from apple: \(word)")
                if let lemmaOfWord = lemmaDB[word.lowercased()] { // because our lemmadDB is all lowercased words
                    print("    >>lemma >>>->>->>found-from-db: \(word): \(lemmaOfWord)")
                    results.append(Word(token: String(text[tokenRange]), lemma: lemmaOfWord))
                } else {
                    print("    >>lemma not-found-even-from-db: \(word)")
                }
//                results.append((tokenRange, word)) // this will be invalid word or incorrect (search lemma from database again)
            }
            return true
        }
        return results
    }

    func name(_ text: String) -> [String: String] {
        var results: [String: String] = [:]
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
//                results.append(String(text[tokenRange]))
                let name = String(text[tokenRange])
                let x = name.split(separator: " ", maxSplits: 1) // ?!
                let firstTokenOfName = String(x[0])
                results[firstTokenOfName] = name
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
    
    func phrase(_ sentence: String) -> [String: String] {
        let lc = withPrint("  lC:", lexicalClass(sentence))
        var pResult: [String: String] = [:]
        for (index, (word, lexicalClass)) in lc.enumerated() {
            if index > 2 {
                let (ppreWord, ppreLexicalClass) = lc[index - 2]
                let (preWord, preLexicalClass) = lc[index - 1]
                if ppreLexicalClass == "Verb" && preLexicalClass == "Adverb" && lexicalClass == "Particle" { // e.g: look forward to
                    let phrase = "\(ppreWord) \(preWord) \(word)"
                    pResult[ppreWord] = phrase
                }
            }
            
            if index > 1 {
                let (preWord, preLexicalClass) = lc[index - 1]
                if (preLexicalClass == "Verb" && lexicalClass == "Preposition") // e.g: take off
                    || (preLexicalClass == "Verb" && lexicalClass == "Particle") // e.g:
                    || (preLexicalClass == "Verb" && lexicalClass == "Adverb") // e.g: fall flat
//                    || (preLexicalClass == "Noun" && lexicalClass == "Noun") // e.g: city state // Many noise word are recognized as Noun!!
                    || (preLexicalClass == "Adjective" && lexicalClass == "Noun") // e.g: open air
                    || (preLexicalClass == "Preposition" && lexicalClass == "Determiner") // e.g: after all
                    || (preLexicalClass == "Noun" && lexicalClass == "Preposition") // e.g: sort of
                    {
                    let phrase = "\(preWord) \(word)"
                    pResult[preWord] = phrase
                }
            }
        }
        return pResult
    }

    func processSingle(_ text: String) -> [String] {
        let origin = withPrint("  sentence:", text)
        
        let tokens = withPrint("  tokenize word:", tokenize(origin, .word))
        let sentence = tokens.joined(separator: " ")
        print("sentence:\(sentence)")
        let originNames = withPrint("  originName:", name(sentence))
        print("originNames:\(originNames)")
        let originPhrases = withPrint("  originPhrases:", phrase(sentence))
        print("originPhrases:\(originPhrases)")

        let lemmas = withPrint("  lemma:", lemma(sentence))
        let lemmaedSentence = lemmas.map{ $0.lemma }.joined(separator: " ")
        print("lemmaedSentence:\(lemmaedSentence)")
        let lemmaedNames = withPrint("  lemmaedName:", name(lemmaedSentence))
        print("lemmaedNames:\(lemmaedNames)")
        let lemmaedPhrases = withPrint("  lemmaedPhrases:", phrase(lemmaedSentence))
        print("lemmaedPhrases:\(lemmaedPhrases)")
        
        var result: [String] = []
        for word in lemmas {
            let token = word.token
            let lemma = word.lemma
            result.append(lemma)
            if let name = originNames[token] {
                if name == token {
                    // don't append when name and token is the same string
                    continue
                }
                result.append(name)
            }
            if let name = lemmaedNames[lemma] {
                if name == lemma {
                    // don't append when name and lemma is the same string
                    continue
                }
                if let originName = originNames[lemma] {
                    if originName == name {
                        // don't append the same
                        continue
                    }
                }
                result.append(name)
            }
            if let phrase = originPhrases[token] {
                result.append(phrase)
            }
            if let phrase = lemmaedPhrases[lemma] {
                if let originPhrase = originPhrases[lemma] {
                    if originPhrase == phrase {
                        // don't append the same
                        continue
                    }
                }
                result.append(phrase)
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
        
        return results

//        let results2 = results.filter { word in
//            for char in word {
//                if !TextProcess.validEnglishWordsCharacterSet.contains(char) {
//                    print(">>>> invalid word:\(word)")
//                    return false
//                }
//            }
//            return true
//        }
    
//        // de duplicate
//        let deDuplicated = NSOrderedSet(array: results2).map({ $0 as! String })
//        return deDuplicated
    }
}

let nplSample = NPLSample()
