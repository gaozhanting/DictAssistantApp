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
    mutateDisplayedWords(wordCell)
}

private func tagWord(_ word: String) -> WordCell {
    if knownSet.contains(word) {
        return WordCell(word: word, isKnown: .known, trans: "") // here, not query trans of known words (no matter toggle show or not show known), aim to as an app optimize !
    } else {
        if let trans = cachedDictionaryServicesDefine(word) {
            return WordCell(word: word, isKnown: .unKnown, trans: trans)
        } else {
            logger.info("   !>>>> translation not found from dicts of word: \(word)")
            return WordCell(word: word, isKnown: .unKnown, trans: "")
        }
    }
}

private func mutateDisplayedWords(_ taggedWordTrans: [WordCell]) {
    let isWithAnimation = UserDefaults.standard.bool(forKey: IsWithAnimationKey)
    if isWithAnimation {
        withAnimation(whichAnimation()) {
            displayedWords.wordCells = taggedWordTrans
        }
    }
    else {
        displayedWords.wordCells = taggedWordTrans
    }
}

private func whichAnimation() -> Animation? {
    let maximumFrameRate = UserDefaults.standard.double(forKey: MaximumFrameRateKey)
    let duration = Double(1 / maximumFrameRate)
    
    let contentStyle = ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))
    if contentStyle == .landscape {
        return Animation.linear(duration: duration)
    } else {
        return Animation.easeInOut(duration: duration)
    }
}
