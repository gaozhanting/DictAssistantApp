//
//  ModelData.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/30.
//

import Foundation
import Combine

final class ModelData: ObservableObject {
    @Published var allWords: [String] = ["sample 1", "sample 2"]
    
    func add(words: String) {
        allWords.append(words)
    }
    
    func reset() {
        allWords = []
    }
}


