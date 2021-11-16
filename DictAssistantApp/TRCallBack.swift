//
//  TRCallBack.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import SwiftUI

// cache for maually refresh
var currentTRTexts: [String] = []

func trCallBack() {
    if !statusData.isPlaying { // do nothing when not playing, this will execute when manually trigger trCallBack() for refresh
        return
    }
    
    let processed = nlpSample.process(currentTRTexts)
    
    let wordCell = processed.map { tagWord($0) }
    
    let isShowPhrase = UserDefaults.standard.bool(forKey: IsShowPhrasesKey)
    let primitiveWordCell = isShowPhrase ? wordCell : wordCell.filter { !$0.word.isPhrase }
    
    mutateDisplayedWords(primitiveWordCell)
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
