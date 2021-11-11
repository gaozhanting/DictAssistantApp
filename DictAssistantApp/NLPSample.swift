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
            
            if level == .db || level == .open {
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
    
    func isInPhraseSet(_ phrase: String) -> Bool {
        return phrasesSet.contains(phrase)
    }
    
    func phrase(_ words: [String]) -> [Int: String] {
        var result: [Int: String] = [:]
        for (index, word) in words.enumerated() {
            // notice this way insert result, long phrase will override the shorter phrase of the same index, that seems reasonable.
            if index >= 1 {
                let phrase = "\(words[index-1]) \(word)"
                if isInPhraseSet(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 2 {
                let phrase = "\(words[index-2]) \(words[index-1]) \(word)"
                if isInPhraseSet(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 3 {
                let phrase = "\(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if isInPhraseSet(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 4 {
                let phrase = "\(words[index-4]) \(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if isInPhraseSet(phrase) {
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
                if isInPhraseSet(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
            
            if index >= 2 {
                let hyphenPhrase = "\(words[index-2])-\(words[index-1])-\(word)" // ignore mixing phrases: i.e: 'a-b c' (too complicated)
                if isInPhraseSet(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
            
            if index >= 3 {
                let hyphenPhrase = "\(words[index-3])-\(words[index-2])-\(words[index-1])-\(word)"
                if isInPhraseSet(hyphenPhrase) {
                    result[index] = hyphenPhrase
                }
            }
        }
        return result
    }

    func processSingle(_ text: String) -> [String] {
        let primitiveTokens = tokenize(text, .word)
        let primitiveSentence = primitiveTokens.joined(separator: " ")
        logger.info("   >> primitiveSentence: \(primitiveSentence, privacy: .public)")

        let words = word(primitiveSentence)
        let tokens = words.map { $0.token }
        let lemmas = words.map { $0.lemma }
        
        let lemmaedSentence = lemmas.joined(separator: " ")
        logger.info("   >> lemmaedSentence: \(lemmaedSentence, privacy: .public)")
                
        let primitiveNames = name(primitiveSentence)
        logger.info("   >> primitiveNames: \(primitiveNames, privacy: .public)")
        let lemmaedNames = name(lemmaedSentence)
        logger.info("   >> lemmaedNames: \(lemmaedNames, privacy: .public)")
        
        let primitivePhrases = phrase(tokens)
        logger.info("   >> primitivePhrases: \(primitivePhrases, privacy: .public)")
        let lemmaedPhrases = phrase(lemmas)
        logger.info("   >> lemmaedPhrases: \(lemmaedPhrases, privacy: .public)")
        
        let primitiveHyphenPhrases = hyphenPhrase(tokens)
        logger.info("   >> primitiveHyphenPhrases: \(primitivePhrases, privacy: .public)")
        let lemmaedHyphenPhrases = hyphenPhrase(lemmas)
        logger.info("   >> lemmaedHyphenPhrases: \(lemmaedPhrases, privacy: .public)")
        
        var result: [String] = []
        
        // mix (merge lemma, name, and phrase)
        for (index, word) in words.enumerated() {
            switch TitleWord(rawValue: UserDefaults.standard.integer(forKey: TitleWordKey))! {
            case .lemma:
                result.append(word.lemma)
            case .primitive:
                result.append(word.token)
            }
            
            // add the indexed primitiveName or lemmaedName, only one added, primitiveName first
            if let primitiveName = primitiveNames[index] {
                if primitiveName.caseInsensitiveCompare(word.lemma) != .orderedSame {
                    result.append(primitiveName)
                    logger.info("   >>> append primitiveName: \(primitiveName, privacy: .public)")
                }
            } else {
                if let lemmaedName = lemmaedNames[index] {
                    if lemmaedName.caseInsensitiveCompare(word.lemma) != .orderedSame {
                        result.append(lemmaedName)
                        logger.info("   >>> append lemmaedName: \(lemmaedName, privacy: .public)")
                    }
                }
            }
            
            // add primitivePhrase
            if let primitivePhrase = primitivePhrases[index] {
                let primitiveName = primitiveNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                if primitivePhrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
                    primitivePhrase.caseInsensitiveCompare(lemmaedName) != .orderedSame { // name first, de-duplicate
                    result.append(primitivePhrase)
                    logger.info("   >>> append primitivePhrase: \(primitivePhrase, privacy: .public)")
                }
            }
            
            // add lemmaedPhrase; lemmaedPhrase still need to add, here not like name
            if let lemmaedphrase = lemmaedPhrases[index] {
                let primitiveName = primitiveNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                let primitivePhrase = primitivePhrases[index] ?? ""
                if lemmaedphrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
                    lemmaedphrase.caseInsensitiveCompare(lemmaedName) != .orderedSame &&
                    lemmaedphrase.caseInsensitiveCompare(primitivePhrase) != .orderedSame { // name first, de-duplicate
                    result.append(lemmaedphrase)
                    logger.info("   >>> append lemmaedPhrase: \(lemmaedphrase, privacy: .public)")
                }
            }
            
            if let primitiveHyphenPhrase = primitiveHyphenPhrases[index] {
                let primitivePhrase = primitivePhrases[index] ?? ""
                if primitiveHyphenPhrase.replacingOccurrences(of: "-", with: " ").caseInsensitiveCompare(primitivePhrase) != .orderedSame {
                    result.append(primitiveHyphenPhrase)
                }
                logger.info("   >>> append primitiveHyphenPhrase: \(primitiveHyphenPhrase, privacy: .public)")
            }
            
            if let lemmaedHyphenPhrase = lemmaedHyphenPhrases[index] {
                let primitiveHyphenPhrase = primitiveHyphenPhrases[index] ?? ""
                let lemmaedPhrase = lemmaedPhrases[index] ?? ""
                if lemmaedHyphenPhrase.caseInsensitiveCompare(primitiveHyphenPhrase) != .orderedSame &&
                    lemmaedHyphenPhrase.replacingOccurrences(of: "-", with: " ").caseInsensitiveCompare(lemmaedPhrase) != .orderedSame {
                    result.append(lemmaedHyphenPhrase)
                    logger.info("   >>> append lemmaedHyphenPhrase: \(lemmaedHyphenPhrase, privacy: .public)")
                }
            }
            
        }
        
        return result
    }
    
    // >>>>  is good for filter console log to get a summary of process
    // >>> append log
    // >> sentence, names, phrase log
    // > lemma log
    func process(_ texts: [String]) -> [String] {
        logger.info("🦉 >>>> NLP process:")

        // for debug
        for text in texts {
            logger.info("   >>>> text from TR: \(text, privacy: .public)")
        }
        
        // transform TR texts into multi sentences
        let primitiveSentences = texts.joined(separator: " ")
        let sentences = tokenize(primitiveSentences, .sentence)
        
        // for every sentence
        var results: [String] = []
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
