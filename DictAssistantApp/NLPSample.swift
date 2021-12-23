//
//  NLPSample.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/1.
//

import Foundation
import NaturalLanguage
import DataBases

extension String {
    var containsNumber: Bool {
        self.contains { c in c.isNumber }
    }
}

let lemmaDB = LemmaDB.read(from: "lemma.en.txt") // take 0.38s

struct NLPSample {
    func tokenize(_ sentence: String, _ tokenUnit: NLTokenUnit) -> [String] {
        var result: [String] = []
        let tokenizer = NLTokenizer(unit: tokenUnit)
        tokenizer.string = sentence
        tokenizer.enumerateTokens(in: tokenizer.string!.startIndex..<tokenizer.string!.endIndex) { tokenRange, _ in
            let token = String(sentence[tokenRange])
            if tokenUnit == .word {
                if !token.containsNumber && !noisesSet.contains(token) {
                    result.append(token)
                }
            } else if tokenUnit == .sentence {
                result.append(token)
            }
            return true
        }
        return result
    }
    
    struct Word: Equatable, Hashable {
        let token: String
        let lemma: String
    }

    // use nlp lemma, if no result, use lemmaDB, if still no result, use self as lemma
    func word(_ sentence: String) -> [Word] {
        var results: [Word] = []
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = sentence
        let range = tagger.string!.startIndex..<tagger.string!.endIndex
        tagger.setLanguage(.english, range: range)
        let options: NLTagger.Options = [
            .omitWhitespace,
            .omitOther,
            .joinContractions
        ]
        tagger.enumerateTags(in: range, unit: .word, scheme: .lemma, options: options) { tag, tokenRange in
            let token = String(sentence[tokenRange])

            if let tag = tag {
                if !tag.rawValue.isEmpty {
                    let lemma = tag.rawValue
                    logger.info("   >lemma       found-from-apple: \(token, privacy: .public): \(lemma, privacy: .public)")
                    results.append(Word(token: token, lemma: lemma))
                } else {
                    logger.info("   >lemma from apple, but raw value of tag is empty") // seems to be impossible
                    results.append(Word(token: token, lemma: "???")) // placeholder to keep align of token and lemma
                }
                return true
            }
            
            let level = LemmaSearchLevel(rawValue: UserDefaults.standard.integer(forKey: LemmaSearchLevelKey))
            
            if level == .database || level == .open {
                if let lemma = lemmaDB[token.lowercased()] { // because our lemmadDB is all lowercased words
                    logger.info("   >lemma          found-from-db: \(token, privacy: .public): \(lemma, privacy: .public)")
                    results.append(Word(token: token, lemma: lemma))
                } else {
                    if level == .open {
                        logger.info("   >lemma not-found-even-from-db: \(token, privacy: .public)")
                        results.append(Word(token: token, lemma: token)) // lemma self as last rescue ===> ignored when can't look up from dictionaries, refer func tagWords
                    }
                }
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
                let untilLastText = sentence[sentence.startIndex..<tokenRange.upperBound]
                let index = untilLastText.filter { char in // search for the word index of the name
                    char == " "
                }.count
                results[index] = name // for mix order
            }
            return true
        }
        return results
    }
    
    func processSingle(_ sentence: String) -> [Word] {
        let primitiveTokens = tokenize(sentence, .word)
        let primitiveSentence = primitiveTokens.joined(separator: " ")
        logger.info("   >>> sentence primitive: \(primitiveSentence, privacy: .public)")

        let words = word(primitiveSentence)
        
        // detectNames
        var primitiveNames: [Int: String] = [:]
        var lemmaedNames: [Int: String] = [:]
        if UserDefaults.standard.bool(forKey: DoNameRecognitionKey) {
            primitiveNames = name(primitiveSentence)
            logger.info("   >>> names primitive: \(primitiveNames, privacy: .public)")
            
            let lemmaedSentence = words.map { $0.lemma }.joined(separator: " ")
            logger.info("   >>> sentence lemmaed  : \(lemmaedSentence, privacy: .public)")
            lemmaedNames = name(lemmaedSentence)
            logger.info("   >>> names lemmaed  : \(lemmaedNames, privacy: .public)")
        }
        
        // mix (merge lemma, name, and phrase)
        // scanning
        var result: [Word] = []
        for (index, word) in words.enumerated() {
            result.append(word)
               
            // appendNames
            // add the indexed primitiveName or lemmaedName, only one added, primitiveName first
            if UserDefaults.standard.bool(forKey: DoNameRecognitionKey) {
                if let primitiveName = primitiveNames[index] {
                    if primitiveName.caseInsensitiveCompare(word.lemma) != .orderedSame {
                        result.append(Word(token: primitiveName, lemma: primitiveName))
                        logger.info("   >>> append name primitive: \(primitiveName, privacy: .public)")
                    }
                } else {
                    if let lemmaedName = lemmaedNames[index] {
                        if lemmaedName.caseInsensitiveCompare(word.lemma) != .orderedSame {
                            result.append(Word(token: lemmaedName, lemma: lemmaedName)) // need code
                            logger.info("   >>> append name lemmaed: \(lemmaedName, privacy: .public)")
                        }
                    }
                }
            }

            func detectAndAppendPhrase(_ tPhrase: String, _ lPhrase: String, _ thPhrase: String, _ lhPhrase: String) {
                if phrasesSet.contains(tPhrase) {
                    result.append(Word(token: tPhrase, lemma: tPhrase))
//                    logger.info("   >>> append t: tPhrase: \(tPhrase, privacy: .public) tPhrase: \(tPhrase, privacy: .public)")
                } else if phrasesSet.contains(lPhrase) {
                    result.append(Word(token: tPhrase, lemma: lPhrase))
//                    logger.info("   >>> append l: tPhrase: \(lPhrase, privacy: .public) lPhrase: \(lPhrase, privacy: .public)")
                } else if phrasesSet.contains(thPhrase) {
                    result.append(Word(token: tPhrase, lemma: thPhrase))
                } else if phrasesSet.contains(lhPhrase) {
                    result.append(Word(token: tPhrase, lemma: lhPhrase))
                }
            }
            
            func scanPhrases() {
                if index >= 1 {
                    let tPhrase = "\(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-1].lemma)-\(word.lemma)"
                    detectAndAppendPhrase(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 2 {
                    let tPhrase = "\(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detectAndAppendPhrase(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 3 {
                    let tPhrase = "\(words[index-3].token) \(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-3].lemma) \(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-3].token)-\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-3].lemma)-\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detectAndAppendPhrase(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 4 {
                    let tPhrase = "\(words[index-4].token) \(words[index-3].token) \(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-4].lemma) \(words[index-3].lemma) \(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-4].token)-\(words[index-3].token)-\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-4].lemma)-\(words[index-3].lemma)-\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detectAndAppendPhrase(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
            }
            
            if UserDefaults.standard.bool(forKey: DoPhraseDetectionKey) {
                scanPhrases()
            }
        }
        return result
    }
    
    // >>>>  is good for filter console log to get a summary of process
    // >>> append log
    // >> sentence, names, phrase log
    // > lemma log
    func process(_ trTexts: [String]) -> [Word] {
        logger.info("🦉 >>>> NLP process:")

        // for debug
        for text in trTexts {
            logger.info("   >>>> text from TR: \(text, privacy: .public)")
        }
        
        // transform TR texts into multi sentences
        let trTextss = trTexts.joined(separator: " ")
        let sentences = tokenize(trTextss, .sentence)
        
        // for every sentence
        var results: [Word] = []
        for sentence in sentences {
            logger.info("   >>>> 🐱 sentence: \(sentence, privacy: .public)")
            
            let result = processSingle(sentence)
            
            logger.info("   >>>> 🐶 result (token: lemma):")
            for r in result {
                logger.info("   >>>> \(r.token, privacy: .public): \(r.lemma, privacy: .public)")
            }
            
            results += result
        }
        
//        logger.info("   >>>> NLP process results    : \(results, privacy: .public)")
        return results
    }
}

let nlpSample = NLPSample()
