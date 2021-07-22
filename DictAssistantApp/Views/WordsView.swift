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

fileprivate enum Style {
    case landscapeNormal
    case landscapeMini
    case portraitNormal
    case portraitMini
}

fileprivate struct SingleWordView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.addToKnownWords) var addToKnownWords
    @Environment(\.removeFromKnownWords) var removeFromKnownWords
    @AppStorage(IsAddLineBreakKey) private var isAddLineBreak: Bool = true
    @AppStorage(FontRateKey) private var fontRate: Double = 0.6

    let wordCell: WordCell
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    let style: Style

    var isKnown: IsKnown {
        wordCell.isKnown
    }
    
    var unKnown: Bool {
        isKnown == .unKnown
    }
    
    var known: Bool {
        isKnown == .known
    }
    
    var word: String {
        wordCell.word
    }
    
    var isPhrase: Bool {
        word.contains(" ")
    }
    
    var trans: String {
        wordCell.trans
    }
    
    var transText: String {
        isAddLineBreak ? "\n" + trans : trans
    }

    func openExternalDict(_ word: String) {
        let replaceSpaced = word.replacingOccurrences(of: " ", with: "-")
        guard let url = URL(string: "https://www.collinsdictionary.com/dictionary/english/\(replaceSpaced)") else {
            logger.info("invalid external dict url string")
            return
        }
        openURL(url)
    }
    
    var textView: some View {
        unKnown ?
            (Text(word).foregroundColor(Color(color)).font(Font.custom(fontName, size: fontSize)) + Text(transText).foregroundColor(.white).font(Font.custom(fontName, size: fontSize * CGFloat(fontRate))))
            :
            Text(word).foregroundColor(.gray)
    }
    
    var body: some View {
        VStack {
            textView
                .opacity( (known && isPhrase) ? 0.5 : 1)
                .font(Font.custom(fontName, size: fontSize))
                .padding(.vertical, 4)
                .padding(.horizontal, 6)
                .contextMenu {
                    Button(unKnown ? "Add to Known" : "Remove from known", action: {
                        unKnown ? addToKnownWords(word) : removeFromKnownWords(word)
                    })
                    Menu("Online Dict Link") {
                        Button("Collins", action: { openExternalDict(word) })
                    }
                }
                .onTapGesture(count: 2) {
                    openDict(word)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Color.black.opacity(style == .landscapeMini ? 0.75 : 0))
            
            Spacer()
        }
    }
}

struct WordCellWithId: Identifiable {
    let wordCell: WordCell
    let id: String
}

fileprivate struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false

    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    let style: Style
    
    var wordCells: [WordCell] {
        isShowPhrase ?
            displayedWords.wordCells :
            displayedWords.wordCells.filter { !$0.word.contains(" ") }
    }
    
    var words: [WordCellWithId] {
        if isShowCurrentKnown {
            var attachedId: [WordCellWithId] = []
            var auxiliary: [String:Int] = [:]
            for wordCell in wordCells {
                let word = wordCell.word
                auxiliary[word, default: 0] += 1
                let id = "\(word)_\(auxiliary[word]!)"
                attachedId.append(WordCellWithId(wordCell: wordCell, id: id))
            }
            return attachedId
        }
        else {
            var deDuplicated: [WordCellWithId] = []
            var auxiliary: Set<String> = Set.init()
            for wordCell in wordCells {
                let word = wordCell.word
                if !auxiliary.contains(word) {
                    deDuplicated.append(WordCellWithId(wordCell: wordCell, id: word))
                    auxiliary.insert(word)
                }
            }
            return deDuplicated.filter{ $0.wordCell.isKnown == .unKnown }
        }
    }
    
    var body: some View {
        ForEach(words) { wordCellWithId in
            let wordCell = wordCellWithId.wordCell
            SingleWordView(
                wordCell: wordCell,
                color: color,
                fontName: fontName,
                fontSize: fontSize,
                style: style)
        }
    }
}

struct LandscapeNormalWordsView: View {
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

struct LandscapeMiniWordsView: View {
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

struct PortraitNormalWordsView: View {
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

struct PortraitMiniWordsView: View {
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

struct WordsView_Previews: PreviewProvider {
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
