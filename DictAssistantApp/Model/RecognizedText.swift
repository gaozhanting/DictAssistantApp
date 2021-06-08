//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine
import Cocoa
import DataBases

class RecognizedText: ObservableObject {
    @Published var texts: [String] = []
    
    var words: [String] {
        TextProcess.extractWords(from: texts)
    }
    
    init(texts: [String] = []) {
        self.texts = texts
    }
}
