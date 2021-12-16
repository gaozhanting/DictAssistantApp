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
    
    struct Word {
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
    
    func phrase(_ words: [String]) -> [Int: String] {
        var result: [Int: String] = [:]
        for (index, word) in words.enumerated() {
            // notice this way insert result, long phrase will override the shorter phrase of the same index, that seems reasonable.
            if index >= 1 {
                let phrase = "\(words[index-1]) \(word)"
                if phrasesSet.contains(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 2 {
                let phrase = "\(words[index-2]) \(words[index-1]) \(word)"
                if phrasesSet.contains(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 3 {
                let phrase = "\(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if phrasesSet.contains(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 4 {
                let phrase = "\(words[index-4]) \(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if phrasesSet.contains(phrase) {
                    result[index] = phrase
                }
            }
        }
        return result
    }
    
    func hyphenPhrase(_ words: [String]) -> [Int: String] {
        var result: [Int: String] = [:]
        for (index, word) in words.enumerated() {
            if index >= 1 {
                let hyphenPhrase = "\(words[index-1])-\(word)"
                if phrasesSet.contains(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
            
            if index >= 2 {
                let hyphenPhrase = "\(words[index-2])-\(words[index-1])-\(word)" // ignore mixing phrases: i.e: 'a-b c' (too complicated)
                if phrasesSet.contains(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
            
            if index >= 3 {
                let hyphenPhrase = "\(words[index-3])-\(words[index-2])-\(words[index-1])-\(word)"
                if phrasesSet.contains(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
        }
        return result
    }
    
    func processSingle(_ sentence: String) -> [Word] {
        let primitiveTokens = tokenize(sentence, .word)
        let primitiveSentence = primitiveTokens.joined(separator: " ")
        logger.info("   >> primitiveSentence: \(primitiveSentence, privacy: .public)")

        let words = word(primitiveSentence)
//        let tokens = words.map { $0.token }
//        let lemmas = words.map { $0.lemma }
//
//        let lemmaedSentence = lemmas.joined(separator: " ")
//        logger.info("   >> lemmaedSentence: \(lemmaedSentence, privacy: .public)")
//
//        let primitiveNames = name(primitiveSentence)
//        logger.info("   >> primitiveNames: \(primitiveNames, privacy: .public)")
//        let lemmaedNames = name(lemmaedSentence)
//        logger.info("   >> lemmaedNames: \(lemmaedNames, privacy: .public)")
//
//        let primitivePhrases = phrase(tokens)
//        logger.info("   >> primitivePhrases: \(primitivePhrases, privacy: .public)")
//        let lemmaedPhrases = phrase(lemmas)
//        logger.info("   >> lemmaedPhrases: \(lemmaedPhrases, privacy: .public)")
//
//        let primitiveHyphenPhrases = hyphenPhrase(tokens)
//        logger.info("   >> primitiveHyphenPhrases: \(primitivePhrases, privacy: .public)")
//        let lemmaedHyphenPhrases = hyphenPhrase(lemmas)
//        logger.info("   >> lemmaedHyphenPhrases: \(lemmaedPhrases, privacy: .public)")
        
        var result: [Word] = []
        
        // mix (merge lemma, name, and phrase)
        // scanning
        for (index, word) in words.enumerated() {
            result.append(word)
            
            func detect(_ tPhrase: String, _ lPhrase: String, _ thPhrase: String, _ lhPhrase: String) {
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
                    detect(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 2 {
                    let tPhrase = "\(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detect(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 3 {
                    let tPhrase = "\(words[index-3].token) \(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-3].lemma) \(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-3].token)-\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-3].lemma)-\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detect(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
                if index >= 4 {
                    let tPhrase = "\(words[index-4].token) \(words[index-3].token) \(words[index-2].token) \(words[index-1].token) \(word.token)"
                    let lPhrase = "\(words[index-4].lemma) \(words[index-3].lemma) \(words[index-2].lemma) \(words[index-1].lemma) \(word.lemma)"
                    let thPhrase = "\(words[index-4].token)-\(words[index-3].token)-\(words[index-2].token)-\(words[index-1].token)-\(word.token)"
                    let lhPhrase = "\(words[index-4].lemma)-\(words[index-3].lemma)-\(words[index-2].lemma)-\(words[index-1].lemma)-\(word.lemma)"
                    detect(tPhrase, lPhrase, thPhrase, lhPhrase)
                }
            }
            
            scanPhrases()
   
//            // add the indexed primitiveName or lemmaedName, only one added, primitiveName first
//            if let primitiveName = primitiveNames[index] {
//                if primitiveName.caseInsensitiveCompare(word.lemma) != .orderedSame {
//                    result.append(Word(token: primitiveName, lemma: primitiveName))
//                    logger.info("   >>> append primitiveName: \(primitiveName, privacy: .public)")
//                }
//            } else {
//                if let lemmaedName = lemmaedNames[index] {
//                    if lemmaedName.caseInsensitiveCompare(word.lemma) != .orderedSame {
//                        result.append(Word(token: lemmaedName, lemma: lemmaedName))
//                        logger.info("   >>> append lemmaedName: \(lemmaedName, privacy: .public)")
//                    }
//                }
//            }
//
//            // add primitivePhrase
//            if let primitivePhrase = primitivePhrases[index] {
//                let primitiveName = primitiveNames[index] ?? ""
//                let lemmaedName = lemmaedNames[index] ?? ""
//                if primitivePhrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
//                    primitivePhrase.caseInsensitiveCompare(lemmaedName) != .orderedSame { // name first, de-duplicate
//                    result.append(Word(token: primitivePhrase, lemma: primitivePhrase))
//                    logger.info("   >>> append primitivePhrase: \(primitivePhrase, privacy: .public)")
//                }
//            }
//
//            // add lemmaedPhrase; lemmaedPhrase still need to add, here not like name
//            if let lemmaedphrase = lemmaedPhrases[index] {
//                let primitiveName = primitiveNames[index] ?? ""
//                let lemmaedName = lemmaedNames[index] ?? ""
//                let primitivePhrase = primitivePhrases[index] ?? ""
//                if lemmaedphrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
//                    lemmaedphrase.caseInsensitiveCompare(lemmaedName) != .orderedSame &&
//                    lemmaedphrase.caseInsensitiveCompare(primitivePhrase) != .orderedSame { // name first, de-duplicate
//                    result.append(Word(token: lemmaedphrase, lemma: lemmaedphrase))
//                    logger.info("   >>> append lemmaedPhrase: \(lemmaedphrase, privacy: .public)")
//                }
//            }
//
//            if let primitiveHyphenPhrase = primitiveHyphenPhrases[index] {
//                let primitivePhrase = primitivePhrases[index] ?? ""
//                if primitiveHyphenPhrase.replacingOccurrences(of: "-", with: " ").caseInsensitiveCompare(primitivePhrase) != .orderedSame {
//                    result.append(Word(token: primitiveHyphenPhrase, lemma: primitiveHyphenPhrase))
//                }
//                logger.info("   >>> append primitiveHyphenPhrase: \(primitiveHyphenPhrase, privacy: .public)")
//            }
//
//            if let lemmaedHyphenPhrase = lemmaedHyphenPhrases[index] {
//                let primitiveHyphenPhrase = primitiveHyphenPhrases[index] ?? ""
//                let lemmaedPhrase = lemmaedPhrases[index] ?? ""
//                if lemmaedHyphenPhrase.caseInsensitiveCompare(primitiveHyphenPhrase) != .orderedSame &&
//                    lemmaedHyphenPhrase.replacingOccurrences(of: "-", with: " ").caseInsensitiveCompare(lemmaedPhrase) != .orderedSame {
//                    result.append(Word(token: lemmaedHyphenPhrase, lemma: lemmaedHyphenPhrase))
//                    logger.info("   >>> append lemmaedHyphenPhrase: \(lemmaedHyphenPhrase, privacy: .public)")
//                }
//            }
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
            logger.info("   >>>> 🐶 result: \(result, privacy: .public)")
            results += result
        }
        
        logger.info("   >>>> NLP process results    : \(results, privacy: .public)")
        return results
    }
}

let nlpSample = NLPSample()
