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
    @EnvironmentObject var smallConfig: SmallConfig

    let taggedWordTrans: (String, String, String)
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    let style: Style

    var tag: String {
        taggedWordTrans.0
    }
    
    var word: String {
        taggedWordTrans.1
    }
    
    var trans: String {
        taggedWordTrans.2
    }
    
    var isPhrase: Bool {
        word.contains(" ")
    }
    
    var transText: String {
        smallConfig.addLineBreak ? "\n" + trans : trans
    }
    
    var unKnown: Bool {
        tag == "unKnown"
    }
    
    var known: Bool {
        tag == "known"
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
            (Text(word).foregroundColor(Color(color)).font(Font.custom(fontName, size: fontSize)) + Text(transText).foregroundColor(.white).font(Font.custom(fontName, size: fontSize * smallConfig.fontRate)))
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

fileprivate struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    @EnvironmentObject var smallConfig: SmallConfig
    
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    let style: Style
    
    var words: [(String, String, String)] {
        if smallConfig.isDisplayKnownWords {
            return displayedWords.words
        } else {
            var deDuplicated: [(String, String, String)] = []
            var tempSet: Set<String> = Set.init()
            for (tag, word, trans) in displayedWords.words {
                if !tempSet.contains(word) {
                    deDuplicated.append((tag, word, trans))
                    tempSet.insert(word)
                }
            }
            return deDuplicated.filter{ $0.0 == "unKnown" }
        }
    }
    
    var body: some View {
        ForEach(words, id: \.1) { taggedWordTrans in
            SingleWordView(
                taggedWordTrans: taggedWordTrans,
                color: color,
                fontName: fontName,
                fontSize: fontSize,
                style: style)
        }
    }
}

struct AttachContextMenu: ViewModifier {
    @EnvironmentObject var textProcessConfig: TextProcessConfig
    @EnvironmentObject var smallConfig: SmallConfig

    let fontRates: [CGFloat] = [0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
    
    func body(content: Content) -> some View {
        content
            .contextMenu {
                Button("\(!smallConfig.isDisplayKnownWords ? "Display" : "Hide") current Known", action: {
                    smallConfig.isDisplayKnownWords.toggle()
                })
                
                Picker(selection: $smallConfig.addLineBreak, label: Text("Add line break: \(smallConfig.addLineBreak ? "Add" : "Not Add")")) {
                    Text("Not Add").tag(false)
                    Text("Add").tag(true)
                }
                
                Picker(selection: $smallConfig.fontRate, label: Text("Select fontRate: \(smallConfig.fontRate, specifier: "%.2f")")) {
                    ForEach(fontRates, id: \.self) { rate in
                        Text("\(rate, specifier: "%.2f")").tag(rate)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Menu("MinimumTextHeight: \(textProcessConfig.minimumTextHeight)") {
                    Button("Increase 0.01", action: {
                        textProcessConfig.minimumTextHeight += 0.01
                        intercepteMutatingMinimumTextHeight()
                    })
                    Button("Decrease 0.01", action: {
                        textProcessConfig.minimumTextHeight -= 0.01
                        intercepteMutatingMinimumTextHeight()
                    })
                    Button("Increase 0.1", action: {
                        textProcessConfig.minimumTextHeight += 0.1
                        intercepteMutatingMinimumTextHeight()
                    })
                    Button("Decrease 0.1", action: {
                        textProcessConfig.minimumTextHeight -= 0.1
                        intercepteMutatingMinimumTextHeight()
                    })
                    Button("Reset to \(systemDefaultMinimumTextHeight)", action: {
                        textProcessConfig.minimumTextHeight = systemDefaultMinimumTextHeight
                    })
                }
            }
    }
    
    func intercepteMutatingMinimumTextHeight() {
        if textProcessConfig.minimumTextHeight < 0 {
            textProcessConfig.minimumTextHeight = 0
        }
        if textProcessConfig.minimumTextHeight > 1 {
            textProcessConfig.minimumTextHeight = 1
        }
    }
}

extension View {
    func attachContextMenu() -> some View {
        self.modifier(AttachContextMenu())
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
        .attachContextMenu()
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
        .attachContextMenu()
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
        .attachContextMenu()
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
        .attachContextMenu()
        .ignoresSafeArea()
    }
}

struct WordsView_Previews: PreviewProvider {
    static let displayedWordsNoWords = DisplayedWords(words: [])
    static let displayedWordsSample1 = DisplayedWords(words: [
        ("known", "around", define("around")),
        ("unKnown", "andros", define("andros")),
        ("known", "the", define("the")),
        ("known", "king", define("king")),
        ("known", "start", define("start")),
        ("unKnown", "grant", define("grant")),
        ("unKnown", "s", define("s"))
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
    let smallConfig = SmallConfig(fontRate: 1.0, addLineBreak: true, isDisplayKnownWords: true)
    let textProcessConfig = TextProcessConfig(
        textRecognitionLevel: .fast,
        minimumTextHeight: systemDefaultMinimumTextHeight
    )
    
    func body(content: Content) -> some View {
        content
            .environmentObject(displayedWords)
            .environmentObject(visualConfig)
            .environmentObject(smallConfig)
            .environmentObject(textProcessConfig)
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
