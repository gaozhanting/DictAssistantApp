//
//  TRCallBack.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import SwiftUI
import Vision

// We use cache to reduce nlp work when texts is not changed.
var trTextsCache: [String] = []
// highlight need
var primitiveWordCellCache: [WordCellWithToken] = []

// other refreshing action
func trCallBack() {
    trTextsCache = []
    primitiveWordCellCache = []
    trCallBackWithCache()
}

// mainly called by AVSessionAndTR
func trCallBackWithCache() {
//    // do nothing when not playing, this will execute when manually trigger trCallBack() for refresh
//    if !statusData.isPlaying {
//        return
//    }
    
    guard let trResults = aVSessionAndTR.results else {
        logger.info("trCallBackWithCache: aVSessionAndTR results is empty")
        return
    }
    
    var trTexts: [String] = []
    for observation in trResults {
        let candidate: VNRecognizedText = observation.topCandidates(1)[0]
        let text = candidate.string
        trTexts.append(text)
    }
    
    // if this option on, content won't react to new empty results; useful for using chrome live caption.
    if UserDefaults.standard.bool(forKey: "IsContentRetentionKey") {
        if trTexts.isEmpty {
            logger.info("trCallBackWithCache: content got retention")
            return
        }
    }

    // We mutate primitiveWordCellCache
    func retriveBoxesAndsyncIndices() -> [IndexedBox] {
        if HighlightMode(rawValue: UserDefaults.standard.integer(forKey: "HighlightModeKey"))! == .disabled {
            return []
        }
        
        let unKnownWords = primitiveWordCellCache.filter{ $0.isKnown == .unKnown }.map{ $0.word }
        
        var iboxes: [IndexedBox] = []
        
        var sentryIndex = 0
        var lemmaIndexDict: [String: Int] = [:] // lemma -> index
        
        // scanning: every observation is one line of TR results, we scan them, and build lemmadIndexDict
        for observation in trResults {
            let candidate: VNRecognizedText = observation.topCandidates(1)[0]
            for unknownWord in unKnownWords {
                let lemma = unknownWord.lemma
                let token = unknownWord.token
                let nsRange = (candidate.string as NSString).range(of: token)
                if let range = Range(nsRange, in: candidate.string) {
                    do {
                        let boundingBox = try candidate.boundingBox(for: range)
                        if let boundingBox = boundingBox {
                            
                            if let index = lemmaIndexDict[lemma] {
                                iboxes.append(IndexedBox(
                                    box: (boundingBox.topLeft, boundingBox.bottomRight),
                                    index: index
                                ))
                            } else {
                                sentryIndex += 1
                                lemmaIndexDict[lemma] = sentryIndex
                                
                                iboxes.append(IndexedBox(
                                    box: (boundingBox.topLeft, boundingBox.bottomRight),
                                    index: lemmaIndexDict[lemma]!
                                ))
                            }
                        } else {
                            logger.info("candidate.boundingBox is nil")
                        }
                    } catch {
                        logger.info("failed to get candidate.boundingBox: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        primitiveWordCellCache = primitiveWordCellCache.map { wc in
            var wc = wc
            if let index = lemmaIndexDict[wc.word.lemma] {
                wc.index = index
            }
            return wc
        }
        
        return iboxes
    }
    
    func refreshHighlightUI() {
        hlBox.indexedBoxes = retriveBoxesAndsyncIndices()
    }
    
    // This is why we use this cache, to prevent duplicate nlp work, and prevent duplicate nlp logs
    if trTexts.elementsEqual(trTextsCache) {
        if UserDefaults.standard.bool(forKey: IsAlwaysRefreshHighlightKey) {
            // We run highlight even when trTexts not changed, for example: youtube pause cause its subtitle texts moved although texts not changed.
            refreshHighlightUI()
        } else {
            // ! Not doing this can avoid many Blink, for example: reading
        }
        return
    } else {
        trTextsCache = trTexts
    }
    
    // nlp takes heavy CPU, although less than TR
    let processed = nlpSample.process(trTextsCache)
    let wordCell2 = processed.map { tagWord($0) }
    primitiveWordCellCache = UserDefaults.standard.bool(forKey: IsShowPhrasesKey) ? wordCell2 : wordCell2.filter { !$0.word.lemma.isPhrase }
    
    func refreshUI() {
        hlBox.indexedBoxes = retriveBoxesAndsyncIndices()
        displayedWords.wordCells = primitiveWordCellCache.map { wc2 in
            WordCell(word: wc2.word.lemma, isKnown: wc2.isKnown, trans: wc2.trans, index: wc2.index)
        }
    }
    
    if UserDefaults.standard.bool(forKey: IsWithAnimationKey) {
        withAnimation {
            refreshUI()
        }
    } else {
        refreshUI()
    }

    snapShotCallback()
}

struct WordCellWithToken {
    let word: NLPSample.Word
    let isKnown: IsKnown
    let trans: String
    var index: Int = 0
}

private func tagWord(_ word: NLPSample.Word) -> WordCellWithToken {
    if knownSet.contains(word.lemma) || knownSet.contains(word.lemma.lowercased()) {
         // Here, not query trans of known words (no matter toggle show or not show known), aims to as an App optimization !
        return WordCellWithToken(word: word, isKnown: .known, trans: "")
    } else {
        if let trans = cachedDictionaryServicesDefine(word.lemma) {
            return WordCellWithToken(word: word, isKnown: .unKnown, trans: trans)
        } else {
//            logger.info("   !>>>> translation not found from dicts of word: \(word.lemma, privacy: .public)")
            return WordCellWithToken(word: word, isKnown: .unKnown, trans: "")
        }
    }
}

private func snapShotCallback() {
    if snapshotState == 1 {
        // same as stopPlaying except:
        // not close cropperWindow
        // not close contentWindow
        
        activeCropperWindow()
        cropperWindow.orderFrontRegardless()

        toastOff()
        statusData.isPlaying = false
        statusItem.button?.image = NSImage(named: "EmptyIcon")
        
        aVSessionAndTR.stopScreenCapture()
        
        snapshotState = 0
    }
}
