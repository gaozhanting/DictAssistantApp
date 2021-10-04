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
    let afterNoiseElimination = nlpSample.process(currentTRTexts)
        .filter { !$0.isNumber }
        .filter { !fixedNoiseVocabulary.contains($0) }
        .filter { !noisesSet.contains($0) }
    
    myPrint("🐳 >>>> After noise elimination: \(afterNoiseElimination)")
    myPrint("   >>>> ")
    
    let wordCell = afterNoiseElimination.map { tagWord($0) }

    mutateDisplayedWords(wordCell)
}

private func tagWord(_ word: String) -> WordCell {
    if knownSet.contains(word) {
        return WordCell(word: word, isKnown: .known, trans: "") // here, not query trans of known words (no matter toggle show or not show known), aim to as an app optimize !
    } else {
        if let trans = cachedDictionaryServicesDefine(word) {
            return WordCell(word: word, isKnown: .unKnown, trans: trans)
        } else {
            myPrint("!> translation not found from dicts of word: \(word)")
            return WordCell(word: word, isKnown: .unKnown, trans: "")
        }
    }
}

extension String {
    var isNumber: Bool {
        self.allSatisfy { c in c.isNumber }
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
