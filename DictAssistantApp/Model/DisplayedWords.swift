//
//  DisplayedWords.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/23.
//

import Foundation

enum IsKnown {
    case known
    case unKnown
}

struct WordCell: Equatable {
    let word: String
    let isKnown: IsKnown
    let trans: String
}

// as a bridge of AppDelegate(and our inner system)(write) and WordsView UI(read)
class DisplayedWords: ObservableObject {
    @Published var wordCells: [WordCell] = []
    
    init(wordCells: [WordCell]) {
        self.wordCells = wordCells
    }
}

let displayedWords = DisplayedWords(wordCells: [])
