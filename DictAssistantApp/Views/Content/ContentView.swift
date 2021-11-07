//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

//fileprivate let spacing: CGFloat = 0

struct WordCellWithId: Identifiable, Equatable {
    let wordCell: WordCell
    let id: String
}

extension String {
    var isMultiline: Bool {
        self.contains { c in
            c.isNewline
        }
    }
}

struct ContentView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue
    
    var body: some View {
        switch ContentStyle(rawValue: contentStyle)! {
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
        WordCell(word: "around", isKnown: .known, trans: ""),
//        WordCell(word: "andros", isKnown: .unKnown, trans: define("andros")),
        WordCell(word: "the", isKnown: .known, trans: ""),
        WordCell(word: "king", isKnown: .known, trans: ""),
//        WordCell(word: "gotten", isKnown: .unKnown, trans: define("gotten")),
//        WordCell(word: "grant", isKnown: .unKnown, trans: define("grant")),
//        WordCell(word: "made", isKnown: .unKnown, trans: define("made")),
//        WordCell(word: "make it", isKnown: .unKnown, trans: define("make it")),
//        WordCell(word: "handle", isKnown: .unKnown, trans: define("handle")),
//        WordCell(word: "beauty", isKnown: .unKnown, trans: define("beauty")),
//        WordCell(word: "butcher", isKnown: .unKnown, trans: define("butcher")),
        
//        WordCell(word: "effort", isKnown: .unKnown, trans: define("effort")),
//        WordCell(word: "instilled", isKnown: .unKnown, trans: define("instilled")),
//        WordCell(word: "instilled", isKnown: .unKnown, trans: define("instilled")),
        
        
//        WordCell(word: "fierce", isKnown: .unKnown, trans: define("fierce")),
        WordCell(word: "Dish", isKnown: .unKnown, trans: define("Dish")),
        
        WordCell(word: "superstitious", isKnown: .unKnown, trans: define("superstitious")),

        
        WordCell(word: "and", isKnown: .known, trans: ""),
//        WordCell(word: "recipe", isKnown: .unKnown, trans: define("recipe")),

//        WordCell(word: "make up one's mind", isKnown: .unKnown, trans: define("make up one's mind")),

    ])
    static var previews: some View {
        Group {
            LandscapeWordsView()
                .environmentObject(displayedWords)
                .frame(width: 1000, height: 300)
            
//            PortraitWordsView()
//                .environmentObject(displayedWords)
//                .frame(width: 300, height: 600)
//
//            PortraitWordsView()
//                .environmentObject(displayedWords)
//                .frame(width: 800, height: 500)
        }
    }
}

