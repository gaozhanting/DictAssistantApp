//
//  TRCallBack.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import SwiftUI
import Vision

// we use textsCache to reduce nlp work when texts is not changed.
var textsCache: [String] = []
// highlight need
var primitiveWordCellCache: [WordCell] = []

func trCallBack() {
    if !statusData.isPlaying { // do nothing when not playing, this will execute when manually trigger trCallBack() for refresh
        return
    }
    
    guard let results = aVSessionAndTR.results else {
        logger.info("aVSessionAndTR results is empty")
        return
    }
    
    var texts: [String] = []
    for observation in results {
        let candidate: VNRecognizedText = observation.topCandidates(1)[0]
        let text = candidate.string
        texts.append(text)
    }
    
    // if this option on, content won't react to new empty results; useful for using chrome live caption.
    if UserDefaults.standard.bool(forKey: "IsContentRetentionKey") {
        if texts.isEmpty {
            logger.info("content got retention")
            return
        }
    }
    
    if texts.elementsEqual(textsCache) {
        // i.e: youtube pause cause subtitle texts moved although texts not changed.
        highlight(
            unKnownWords: primitiveWordCellCache.filter{ $0.isKnown == .unKnown }.map{ $0.word },
            results: results
        )
        return
    }
    
    textsCache = texts
    
    let processed = nlpSample.process(textsCache)
    
    let wordCell = processed.map { tagWord($0) }
    
    let primitiveWordCell = UserDefaults.standard.bool(forKey: IsShowPhrasesKey) ? wordCell : wordCell.filter { !$0.word.isPhrase }
    primitiveWordCellCache = primitiveWordCell
    
    mutateDisplayedWords(primitiveWordCellCache)
    
    highlight(
        unKnownWords: primitiveWordCellCache.filter{ $0.isKnown == .unKnown }.map{ $0.word },
        results: results
    )
    
}

private func tagWord(_ word: String) -> WordCell {
    if knownSet.contains(word) || knownSet.contains(word.lowercased()) {
        return WordCell(word: word, isKnown: .known, trans: "") // here, not query trans of known words (no matter toggle show or not show known), aim to as an app optimize !
    } else {
        if let trans = cachedDictionaryServicesDefine(word) {
            return WordCell(word: word, isKnown: .unKnown, trans: trans)
        } else {
            logger.info("   !>>>> translation not found from dicts of word: \(word, privacy: .public)")
            return WordCell(word: word, isKnown: .unKnown, trans: "")
        }
    }
}

private func highlight(unKnownWords: [String], results: [VNRecognizedTextObservation]) {
    var boxs: [(CGPoint, CGPoint)] = []
    
    for observation in results {
        let candidate: VNRecognizedText = observation.topCandidates(1)[0]
        let text = candidate.string
        
        for unknownWord in unKnownWords {
            let nsRange = (text as NSString).range(of: unknownWord)
            if let range = Range(nsRange, in: text) {
                do {
                    let box = try candidate.boundingBox(for: range)
                    if let box = box {
                        boxs.append((box.topLeft, box.bottomRight))
                        //                            logger.info(">>]] set highlightBounds: \(hlBox.boxs)")
                    }
                } catch {
                    logger.info("Failed to get candidate.boundingBox: \(error.localizedDescription)")
                }
            }
        }
    }
    
    hlBox.boxs = boxs
}

private func mutateDisplayedWords(_ taggedWordTrans: [WordCell]) {
    let isWithAnimation = UserDefaults.standard.bool(forKey: IsWithAnimationKey)
    if isWithAnimation {
        withAnimation {
            displayedWords.wordCells = taggedWordTrans
        }
    }
    else {
        displayedWords.wordCells = taggedWordTrans
    }
}
