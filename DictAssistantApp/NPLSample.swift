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

    // use npl lemma, if no result, use lemmaDB, if still no result, use self as lemma
    func word(_ sentence: String) -> [Word] {
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
                    myPrint("    >>lemma from apple, but raw value of tag is empty") // seems to be impossible
                    results.append(Word(token: token, lemma: "???")) // placeholder to keep align of token and lemma
                }
                return true
            }
            
            if let lemma = lemmaDB[token.lowercased()] { // because our lemmadDB is all lowercased words
                myPrint("    >>lemma >>>->>->>found-from-db: \(token): \(lemma)")
                results.append(Word(token: token, lemma: lemma))
            } else {
                myPrint("    !>lemma not-found-even-from-db: \(token)")
                results.append(Word(token: token, lemma: token)) // lemma self as last rescue ===> ignored when can't look up from dictionaries, refer func tagWords
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
                if isPhraseInWhichPhrases(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 2 {
                let phrase = "\(words[index-2]) \(words[index-1]) \(word)"
                if isPhraseInWhichPhrases(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 3 {
                let phrase = "\(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if isPhraseInWhichPhrases(phrase) {
                    result[index] = phrase
                }
            }
            
            if index >= 4 {
                let phrase = "\(words[index-4]) \(words[index-3]) \(words[index-2]) \(words[index-1]) \(word)"
                if isPhraseInWhichPhrases(phrase) {
                    result[index] = phrase
                }
            }
        }
        return result
    }

    func processSingle(_ text: String) -> [String] {
        let primitiveTokens = tokenize(text, .word)
        let primitiveSentence = primitiveTokens.joined(separator: " ")
        myPrint("primitiveSentence:\(primitiveSentence)")

        let words = word(primitiveSentence)
        let tokens = words.map { $0.token }
        let lemmas = words.map { $0.lemma }
        
        let lemmaedSentence = lemmas.joined(separator: " ")
        myPrint("lemmaedSentence:\(lemmaedSentence)")
                
        let primitiveNames = name(primitiveSentence)
        myPrint("primitiveNames:\(primitiveNames)")
        let lemmaedNames = name(lemmaedSentence)
        myPrint("lemmaedNames:\(lemmaedNames)")
        
        let primitivePhrases = phrase(tokens)
        myPrint("primitivePhrases:\(primitivePhrases)")
        let lemmaedPhrases = phrase(lemmas)
        myPrint("lemmaedPhrases:\(lemmaedPhrases)")
        
        var result: [String] = []
        for (index, word) in words.enumerated() {
            result.append(word.lemma)
            
            if let name = primitiveNames[index] {  // primitiveNames first
                if name.caseInsensitiveCompare(word.lemma) != .orderedSame {
                    result.append(name)
                }
            }
            else {
                if let name = lemmaedNames[index] {
                    if name.caseInsensitiveCompare(word.lemma) != .orderedSame {
                        result.append(name)
                    }
                }
            }
            
            if let phrase = primitivePhrases[index] { // primitivePhrase first
                let primitiveName = primitiveNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                if phrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
                    phrase.caseInsensitiveCompare(lemmaedName) != .orderedSame { // name first, de-duplicate
                    result.append(phrase)
                }
            }
            
            if let phrase = lemmaedPhrases[index] { // lemmaedPhrase still need to add, here not like name
                let primitiveName = primitiveNames[index] ?? ""
                let lemmaedName = lemmaedNames[index] ?? ""
                let primitivePhrase = primitivePhrases[index] ?? ""
                if phrase.caseInsensitiveCompare(primitiveName) != .orderedSame &&
                    phrase.caseInsensitiveCompare(lemmaedName) != .orderedSame &&
                    phrase.caseInsensitiveCompare(primitivePhrase) != .orderedSame { // name first, de-duplicate
                    result.append(phrase)
                }
            }
            
        }
        return result
    }
    
    func process(_ texts: [String]) -> [String] {
        // for debug
        for text in texts {
            myPrint(">>>>text from TR: \(text)")
        }
        
        // transform TR texts into multi sentences
        let primitiveSentences = texts.joined(separator: " ")
        let sentences = tokenize(primitiveSentences, .sentence)
        
        // for every sentence
        var results: [String] = []
        myPrint(">>>>NPL process:")
        for sentence in sentences {
            let result = processSingle(sentence)
            myPrint(">>>>sentence: \(sentence)")
            myPrint(">>>>result: \(result)")
            results += result
        }
        
        return results
    }
}

let nplSample = NPLSample()

func isPhraseInWhichPhrases(_ phrase: String) -> Bool {
    return fixedPhrasesSet.contains(phrase) || customPhrasesSet.contains(phrase)
}
