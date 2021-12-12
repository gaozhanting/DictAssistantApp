//
//  TRCallBack.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import SwiftUI
import Vision

// cache for maually refresh
var currentTRTexts: [String] = []

func trCallBack() {
    if !statusData.isPlaying { // do nothing when not playing, this will execute when manually trigger trCallBack() for refresh
        return
    }
    
    let processed = nlpSample.process(currentTRTexts)
    
    let wordCell = processed.map { tagWord($0) }
    
    let primitiveWordCell = UserDefaults.standard.bool(forKey: IsShowPhrasesKey) ? wordCell : wordCell.filter { !$0.word.isPhrase }
    
    mutateDisplayedWords(primitiveWordCell)
    
    highlight(unKnownWords: primitiveWordCell.filter{ $0.isKnown == .unKnown }.map{ $0.word })
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

private func highlight(unKnownWords: [String]) {
    if let results = aVSessionAndTR.results {
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
