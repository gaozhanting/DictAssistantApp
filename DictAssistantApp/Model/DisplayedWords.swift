//
//  DisplayedWords.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/23.
//

import Foundation

// as a bridge of AppDelegate(and our inner system)(write) and WordsView UI(read)
class DisplayedWords: ObservableObject {
    @Published var words: [(String, String, String)] = []
    
    init(words: [(String, String, String)]) {
        self.words = words
    }
}
