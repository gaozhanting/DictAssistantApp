//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Cocoa
import DataBases

class RecognizedText: ObservableObject {
    @Published var texts: [String] = []
    
    var textsCache: [String] = []
    var wordsCache: [String] = []
    
    var words: [String] { // maybe expensive?! add lazy?
        if texts.elementsEqual(textsCache) {
//            logger.info("RecognizedText texts elementsEqual textsCache, so don't do extractWords")
            return wordsCache
        }
        
        logger.info("RecognizedText texts NOT elementsEqual textsCache, so do extractWords")
        textsCache = texts
        wordsCache = TextProcess.extractWords(from: texts)
        return wordsCache
    }
    
    init(texts: [String]) {
        self.texts = texts
    }
}
