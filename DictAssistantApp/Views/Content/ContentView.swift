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

// how to make portrait word pop out from bottom, not from top
struct ContentView: View {
    @State private var showEditingPopover: Bool = false
    
    var body: some View {
        ContentView0()
            .contextMenu {
                Button("Add Custom Dict Entry") {
                    showEditingPopover = true
                }
            }
            .popover(isPresented: $showEditingPopover) {
                EditingCustomEntryView()
            }
    }
}

extension String {
    var isMultiline: Bool {
        self.contains { c in
            c.isNewline
        }
    }
}

private struct EditingCustomEntryView: View {
    @State private var text: String = ""
    
    func add() {
        let txt = text.split(separator: Character(","), maxSplits: 1)
        let word = String(txt[0])
        let trans = String(txt[1])
        if word.isPhrase {
            addPhrase(word)
        }
        let entry = Entry()
        entry.word = word
        entry.trans = trans
        upsertEntry(entry)
    }
    
    func valid() -> Bool {
        !text.isMultiline &&
            text.split(separator: Character(","), maxSplits: 1)
                .count == 2
    }
    
    var body: some View {
        HStack {
            TextField("Add Custom Dict Entry", text: $text)
            
            Button(action: add) {
                Image(systemName: "rectangle.badge.plus")
            }
            .disabled(!valid())
            .keyboardShortcut(KeyEquivalent.return)
        }
        .frame(width: 440)
        .padding(.horizontal)
        .padding(.vertical, 2)
    }
}

struct ContentView0: View {
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
//        WordCell(word: "around", isKnown: .known, trans: define("around")),
//        WordCell(word: "andros", isKnown: .unKnown, trans: define("andros")),
//        WordCell(word: "the", isKnown: .known, trans: define("the")),
//        WordCell(word: "king", isKnown: .known, trans: define("king")),
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

        
//        WordCell(word: "and", isKnown: .known, trans: define("and")),
//        WordCell(word: "recipe", isKnown: .unKnown, trans: define("recipe")),

//        WordCell(word: "make up one's mind", isKnown: .unKnown, trans: define("make up one's mind")),

    ])
    static var previews: some View {
        Group {
            LandscapeWordsView()
                .environmentObject(displayedWords)
                .frame(width: 1000, height: 300)
            
            PortraitWordsView()
                .environmentObject(displayedWords)
                .frame(width: 300, height: 600)
            
            PortraitWordsView()
                .environmentObject(displayedWords)
                .frame(width: 800, height: 500)
        }
    }
}

