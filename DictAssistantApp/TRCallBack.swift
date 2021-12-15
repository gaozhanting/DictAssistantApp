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
var primitiveWordCellCache: [WordCell] = []

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

    // because we mutate primitiveWordCellCache
    func highlightAndNumbered() {
        if HighlightMode(rawValue: UserDefaults.standard.integer(forKey: "HighlightModeKey"))! == .disabled {
            hlBox.boxs = []
        }
        let unKnownWords = primitiveWordCellCache.filter{ $0.isKnown == .unKnown }.map{ $0.word }
        var boxs: [(CGPoint, CGPoint)] = []
        var n: Int = 0
        var auxiliary: Set<String> = Set.init()
        for observation in trResults {
            let candidate: VNRecognizedText = observation.topCandidates(1)[0]
            let text = candidate.string
            
            // don't duplicate found bound box unknown word; unKnownWords may have duplicated which is Okay there, but not here. Here is one line TR result.
            for unknownWord in unKnownWords {
                if auxiliary.contains(unknownWord) { continue }
                let nsRange = (text as NSString).range(of: unknownWord)
                if let range = Range(nsRange, in: text) {
                    do {
                        let box = try candidate.boundingBox(for: range)
                        if let box = box {
                            boxs.append((box.topLeft, box.bottomRight))
                            
                            if UserDefaults.standard.bool(forKey: IsShowNumberKey) {
                                n += 1
                                primitiveWordCellCache = primitiveWordCellCache.map { wc in
                                    var wc = wc // parameter masking to allow local mutation
                                    if wc.word == unknownWord {
                                        //                                    print("number<> n:\(n)")
                                        wc.number = n
                                    }
                                    return wc
                                }
                            }
                            
                            auxiliary.insert(unknownWord)
                            //                        print("box: unknownWord: \(unknownWord); text: \(text)")
                        } else {
                            //                        print("not box: unknownWord: \(unknownWord); text: \(text)")
                        }
                    } catch {
                        logger.info("Failed to get candidate.boundingBox: \(error.localizedDescription)")
                    }
                }
            }
        }
        hlBox.boxs = boxs
        //    print(">>]]>> count of highlightBounds box: \(hlBox.boxs.count)")
        //    for box in hlBox.boxs {
        ////        print(">>]]>> set highlightBounds box: \(box)")
        //    }
    }
        
    // This is why we use this cache, to prevent duplicate nlp work, and prevent duplicate nlp logs
    if trTexts.elementsEqual(trTextsCache) {
        // We run highlight even when trTexts not changed, for example: youtube pause cause subtitle texts moved although texts not changed.
        highlightAndNumbered()
        return
    } else {
        trTextsCache = trTexts
    }
    
    // nlp takes heavy CPU, although less than TR
    let processed = nlpSample.process(trTextsCache)
    let wordCell = processed.map { tagWord($0) }
    primitiveWordCellCache = UserDefaults.standard.bool(forKey: IsShowPhrasesKey) ? wordCell : wordCell.filter { !$0.word.isPhrase }
    
    highlightAndNumbered()
    
    if UserDefaults.standard.bool(forKey: IsWithAnimationKey) {
        withAnimation {
            displayedWords.wordCells = primitiveWordCellCache
        }
    } else {
        displayedWords.wordCells = primitiveWordCellCache
    }

    snapShotCallback()
}

private func tagWord(_ word: String) -> WordCell {
    if knownSet.contains(word) || knownSet.contains(word.lowercased()) {
         // Here, not query trans of known words (no matter toggle show or not show known), aims to as an App optimization !
        return WordCell(word: word, isKnown: .known, trans: "")
    } else {
        if let trans = cachedDictionaryServicesDefine(word) {
            return WordCell(word: word, isKnown: .unKnown, trans: trans)
        } else {
            logger.info("   !>>>> translation not found from dicts of word: \(word, privacy: .public)")
            return WordCell(word: word, isKnown: .unKnown, trans: "")
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
