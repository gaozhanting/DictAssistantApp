//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

fileprivate let defaultMaxWidthOfLandscape: CGFloat = 300.0
fileprivate let defaultMaxHeigthOfPortrait: CGFloat = 200.0
//fileprivate let spacing: CGFloat = 0


struct WordCellWithId: Identifiable {
    let wordCell: WordCell
    let id: String
}

let visualEffectView1: NSVisualEffectView = {
    let ve = NSVisualEffectView()
    ve.material = .contentBackground
    return ve
}()

let visualEffectView2: NSVisualEffectView = {
    let ve = NSVisualEffectView()
    ve.material = .underWindowBackground
    ve.blendingMode = .behindWindow
    return ve
}()

fileprivate struct LandscapeWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                WordsView(
                    color: visualConfig.colorOfLandscape,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfLandscape
                )
                .frame(maxWidth: defaultMaxWidthOfLandscape, maxHeight: .infinity, alignment: .topLeading)
                
                VStack { Spacer() }
            }
        }
        .background(VisualEffectView(visualEffect: visualEffectView1))
    }
}

fileprivate struct PortraitWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait
                )
                .frame(maxWidth: .infinity, maxHeight: defaultMaxHeigthOfPortrait, alignment: .topLeading)

                HStack { Spacer() } // avoid animation shrink
            }
        }
    }
}

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
    static let displayedWordsNoWords = DisplayedWords(wordCells: [])
    static let displayedWordsSample1 = DisplayedWords(wordCells: [
        WordCell(word: "around", isKnown: .known, trans: define("around")),
        WordCell(word: "andros", isKnown: .unKnown, trans: define("andros")),
        WordCell(word: "the", isKnown: .known, trans: define("the")),
        WordCell(word: "king", isKnown: .known, trans: define("king")),
        WordCell(word: "grant", isKnown: .unKnown, trans: define("grant")),
        WordCell(word: "s", isKnown: .unKnown, trans: define("s"))
    ])
    static var previews: some View {
        Group {
            LandscapeWordsView()
                .frame(width: 1000, height: 220)
                .attachEnv(displayedWords: displayedWordsSample1)
            
            PortraitWordsView()
                .frame(width: 220, height: 300)
                .attachEnv(displayedWords: displayedWordsSample1)
        }
    }
}

struct AttachEnv: ViewModifier {
    let displayedWords: DisplayedWords
    let visualConfig = VisualConfig(
        fontSizeOfLandscape: 20,
        fontSizeOfPortrait: 13,
        colorOfLandscape: .orange,
        colorOfPortrait: .green,
        fontName: NSFont.systemFont(ofSize: 0.0).fontName
    )
    
    func body(content: Content) -> some View {
        content
            .environmentObject(displayedWords)
            .environmentObject(visualConfig)
    }
}

extension View {
    func attachEnv(displayedWords: DisplayedWords) -> some View {
        self.modifier(AttachEnv(displayedWords: displayedWords))
    }
}

fileprivate func define(_ word: String) -> String {
    return DictionaryServices.define(word) ?? ""
}
