//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

//fileprivate let spacing: CGFloat = 0

struct WordCellWithId: Identifiable {
    let wordCell: WordCell
    let id: String
}

// how to make portrait word pop out from bottom, not from top

struct ContentView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portrait
    
    var body: some View {
        switch contentStyle {
        case .portrait:
            PortraitWordsView()
        case .landscape:
            LandscapeWordsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static func define(_ word: String) -> String {
        return DictionaryServices.define(word) ?? ""
    }
    static let displayedWords = DisplayedWords(wordCells: [
        WordCell(word: "around", isKnown: .known, trans: define("around")),
        WordCell(word: "andros", isKnown: .unKnown, trans: define("andros")),
        WordCell(word: "the", isKnown: .known, trans: define("the")),
        WordCell(word: "king", isKnown: .known, trans: define("king")),
        WordCell(word: "grant", isKnown: .unKnown, trans: define("grant"))
//        WordCell(word: "s", isKnown: .unKnown, trans: define("s"))
    ])
    static var previews: some View {
        Group {
            LandscapeWordsView()
                .environmentObject(displayedWords)
                .frame(width: 1000, height: 220)
            
            PortraitWordsView()
                .environmentObject(displayedWords)
                .frame(width: 220, height: 600)
            
            PortraitWordsView()
                .environmentObject(displayedWords)
                .frame(width: 800, height: 300)
        }
    }
}

