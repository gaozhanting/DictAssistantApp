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

// when cache not diff, don't refresh highlight UI
var indexedBoxesCache: [IndexedBox] = []

// other refreshing action
func trCallBack() {
    trTextsCache = []
    primitiveWordCellCache = []
    indexedBoxesCache = []
    trCallBackWithCache()
}

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        var seen = Set<Element>()
        var out = [Element]()

        for element in self {
            if !seen.contains(element) {
                out.append(element)
                seen.insert(element)
            }
        }

        return out
    }
}

// mainly called by AVSessionAndTR
func trCallBackWithCache() {
//    // do nothing when not playing, this will execute when manually trigger trCallBack() for refresh
//    if !statusData.isPlaying {
//        return
//    }
    
    // Bug, when first start, the results is empty? Why?
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
    
    // We mutate primitiveWordCellCache
    func retriveBoxesAndsyncIndices() -> [IndexedBox] {
        let unKnownWords = primitiveWordCellCache.filter{ $0.isKnown == .unKnown }.map{ $0.word }.removeDuplicates()
        
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
                            let box = (boundingBox.topLeft, boundingBox.bottomRight)
                            
                            func collect() {
                                if let index = lemmaIndexDict[lemma] {
                                    iboxes.append(IndexedBox(
                                        box: box,
                                        index: index
                                    ))
                                } else {
                                    sentryIndex += 1
                                    lemmaIndexDict[lemma] = sentryIndex
                                    
                                    let index = lemmaIndexDict[lemma]!
                                    iboxes.append(IndexedBox(
                                        box: box,
                                        index: index
                                    ))
                                }
                            }
                            
                            collect()

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
        indexedBoxesCache = retriveBoxesAndsyncIndices()
        if !hlBox.indexedBoxes.elementsEqual(indexedBoxesCache) {
            logger.info("refreshHighlightUI executed, cache diff")
            hlBox.indexedBoxes = indexedBoxesCache
        }
        logger.info("hasShadow = \(UserDefaults.standard.bool(forKey: CropperHasShadowKey)) ")
        if UserDefaults.standard.bool(forKey: CropperHasShadowKey) { // seems resolve shadow bug, but cpu not to 0
            cropperWindow.invalidateShadow()
        }
    }
    
    // This is why we use this cache, to prevent duplicate nlp work, and prevent duplicate nlp logs
    if trTexts.elementsEqual(trTextsCache) {
        logger.info(">>> refreshHighlightUI only")
        refreshHighlightUI()
        return
    } else {
        trTextsCache = trTexts
    }
    
    // nlp takes heavy CPU, although less than TR
    let processed = nlpSample.process(trTextsCache)
    primitiveWordCellCache = processed.map { tagWord($0) }
    
    func refreshUI() {
        logger.info(">>> refreshUI")
        refreshHighlightUI()
        let wordCells = primitiveWordCellCache.map { wc2 in
            WordCell(word: wc2.word.lemma, isKnown: wc2.isKnown, trans: wc2.trans, index: wc2.index)
        }
        let wordCellIds = convertToWordCellWithId(
            from: wordCells,
            isShowKnown: UserDefaults.standard.bool(forKey: IsShowKnownKey),
            isShowKnownButWithOpacity0: UserDefaults.standard.bool(forKey: IsShowKnownButWithOpacity0Key),
            isShowNotFound: UserDefaults.standard.bool(forKey: IsShowNotFoundKey)
        )
        displayedWords.wordCells = wordCellIds
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

func convertToWordCellWithId(
    from primitiveWordCells: [WordCell],
    isShowKnown: Bool,
    isShowKnownButWithOpacity0: Bool,
    isShowNotFound: Bool
) -> [WordCellWithId] {
    let wordCells: [WordCell] = !isShowNotFound ? // default false
    primitiveWordCells.filter { !($0.isKnown == .unKnown && $0.trans.isEmpty) } :
    primitiveWordCells
    
    if isShowKnown || isShowKnownButWithOpacity0 {
        var attachedId: [WordCellWithId] = []
        var auxiliary: [String:Int] = [:]
        for wordCell in wordCells {
            let word = wordCell.word
            auxiliary[word, default: 0] += 1
            let id = "\(word)_\(auxiliary[word]!)"
            attachedId.append(WordCellWithId(wordCell: wordCell, id: id))
        }
        return attachedId
    }
    
    var deDuplicated: [WordCellWithId] = []
    var auxiliary: Set<String> = Set.init()
    for wordCell in wordCells {
        let word = wordCell.word
        if !auxiliary.contains(word) {
            deDuplicated.append(WordCellWithId(wordCell: wordCell, id: word))
            auxiliary.insert(word)
        }
    }
    return deDuplicated.filter{ $0.wordCell.isKnown == .unKnown }
}
