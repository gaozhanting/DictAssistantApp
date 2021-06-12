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
    
    var words: [String] { // maybe expensive?! add lazy?
        TextProcess.extractWords(from: texts)
    }
    
    init(texts: [String]) {
        self.texts = texts
    }
}