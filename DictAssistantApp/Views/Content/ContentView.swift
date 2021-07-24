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

enum Style {
    case landscapeNormal
    case landscapeMini
    case portraitNormal
    case portraitMini
}

struct WordCellWithId: Identifiable {
    let wordCell: WordCell
    let id: String
}

fileprivate struct LandscapeNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                WordsView(
                    color: visualConfig.colorOfLandscape,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfLandscape,
                    style: .landscapeNormal
                )
                .frame(maxWidth: defaultMaxWidthOfLandscape, maxHeight: .infinity, alignment: .topLeading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
        .ignoresSafeArea()
    }
}

fileprivate struct LandscapeMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    WordsView(
                        color: visualConfig.colorOfLandscape,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfLandscape,
                        style: .landscapeMini
                    )
                    .frame(maxWidth: defaultMaxWidthOfLandscape)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

fileprivate struct PortraitNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait,
                    style: .portraitNormal
                )
                .frame(maxWidth: .infinity, maxHeight: defaultMaxHeigthOfPortrait, alignment: .topLeading)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
        .ignoresSafeArea()
    }
}

fileprivate struct PortraitMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        HStack {
            Spacer()
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    WordsView(
                        color: visualConfig.colorOfPortrait,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfPortrait,
                        style: .portraitMini
                    )
                    .frame(maxHeight: defaultMaxHeigthOfPortrait, alignment: .topLeading)
                }
                .background(Color.black.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct ContentView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portraitNormal
    
    var body: some View {
        switch contentStyle {
        case .portraitNormal:
            PortraitNormalWordsView()
        case .portraitMini:
            PortraitMiniWordsView()
        case .landscapeNormal:
            LandscapeNormalWordsView()
        case .landscapeMini:
            LandscapeMiniWordsView()
        }
    }
}

struct ContentNormalView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: ContentStyle = .portraitNormal
    
    var body: some View {
        switch contentStyle {
        case .portraitNormal:
            PortraitNormalWordsView()
        case .portraitMini:
            PortraitNormalWordsView()
        case .landscapeNormal:
            LandscapeNormalWordsView()
        case .landscapeMini:
            LandscapeNormalWordsView()
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
            Group {
                LandscapeNormalWordsView()
                    .frame(width: 1000, height: 220)
                    .attachEnv(displayedWords: displayedWordsSample1)
                LandscapeNormalWordsView()
                    .frame(width: 1000, height: 220)
                    .attachEnv(displayedWords: displayedWordsNoWords)
            }
            
            Group {
                LandscapeMiniWordsView()
                    .frame(width: 1000, height: 220)
                    .attachEnv(displayedWords: displayedWordsSample1)
                LandscapeMiniWordsView()
                    .frame(width: 1000, height: 220)
                    .attachEnv(displayedWords: displayedWordsNoWords)
            }

            Group {
                PortraitNormalWordsView()
                    .frame(width: 220, height: 600)
                    .attachEnv(displayedWords: displayedWordsSample1)
                PortraitNormalWordsView()
                    .frame(width: 220, height: 600)
                    .attachEnv(displayedWords: displayedWordsNoWords)
            }

            Group {
                PortraitMiniWordsView()
                    .frame(width: 220, height: 600)
                    .attachEnv(displayedWords: displayedWordsSample1)
                PortraitMiniWordsView()
                    .frame(width: 220, height: 600)
                    .attachEnv(displayedWords: displayedWordsNoWords)
            }
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
