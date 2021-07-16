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
        if smallConfig.addLineBreak {
            return ("\n" + trans)
        } else {
            return trans
        }
    }
    
    var body: some View {
        if tag == "unKnown" {
            VStack {
                (Text(word).foregroundColor(Color(color)).font(Font.custom(fontName, size: fontSize)) + Text(transText).foregroundColor(.white).font(Font.custom(fontName, size: fontSize * smallConfig.fontRate)))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .contextMenu {
                        Button("Add to Known", action: { addToKnownWords(word) })
                        Menu("Online Dict Link") {
                            Button("Collins", action: {
                                if isPhrase { return }
                                let url = URL(string: "https://www.collinsdictionary.com/dictionary/english/\(word)")
                                NSWorkspace.shared.open(url!)
                            })
                        }
                    }
                    .onTapGesture(count: 2) {
                        openDict(word) // phrase not work!
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color.black.opacity(style == .landscapeMini ? 0.75 : 0))
                
                Spacer()
            }

        } else {
            VStack {
                Text(word).foregroundColor(.gray).opacity( isPhrase ? 0.5 : 1)
                    .font(Font.custom(fontName, size: fontSize))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 6)
                    .contextMenu {
                        Button("Remove from Known", action: { removeFromKnownWords(word) })
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
}

fileprivate struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    @EnvironmentObject var smallConfig: SmallConfig
    
    var isDisplayKnownWords: Bool {
        smallConfig.isDisplayKnownWords
    }
    
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
        
    let style: Style
    
    var words: [(String, String, String)] {
        if isDisplayKnownWords {
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
            return deDuplicated
        }
    }
    
    var body: some View {
        if isDisplayKnownWords {
            ForEach(Array(words.enumerated()), id: \.0) { _, taggedWordTrans in
                SingleWordView(
                    taggedWordTrans: taggedWordTrans,
                    color: color,
                    fontName: fontName,
                    fontSize: fontSize,
                    style: style)
            }
        } else {
            ForEach(Array(words.filter { $0.0 == "unKnown" }.enumerated()), id: \.0) { _, taggedWordTrans in
                SingleWordView(
                    taggedWordTrans: taggedWordTrans,
                    color: color,
                    fontName: fontName,
                    fontSize: fontSize,
                    style: style)
            }
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
                        if textProcessConfig.minimumTextHeight >= 1 {
                            textProcessConfig.minimumTextHeight = 1
                        }
                    })
                    Button("Decrease 0.01", action: {
                        textProcessConfig.minimumTextHeight -= 0.01
                        if textProcessConfig.minimumTextHeight <= 0.0 {
                            textProcessConfig.minimumTextHeight = 0.0
                        }
                    })
                    Button("Increase 0.1", action: {
                        textProcessConfig.minimumTextHeight += 0.1
                        if textProcessConfig.minimumTextHeight >= 1 {
                            textProcessConfig.minimumTextHeight = 1
                        }
                    })
                    Button("Decrease 0.1", action: {
                        textProcessConfig.minimumTextHeight -= 0.1
                        if textProcessConfig.minimumTextHeight <= 0.0 {
                            textProcessConfig.minimumTextHeight = 0.0
                        }
                    })
                    Button("Reset to \(systemDefaultMinimumTextHeight)", action: {
                        textProcessConfig.minimumTextHeight = systemDefaultMinimumTextHeight
                    })
                }
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
        }
        .attachContextMenu()
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct LandscapeMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig

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
        .attachContextMenu()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig

    @State var isDisplayKnownWords: Bool = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait,
                    style: .portraitNormal
                )
                .frame(maxWidth: .infinity, maxHeight: defaultMaxHeigthOfPortrait, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .attachContextMenu()
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig

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
        .attachContextMenu()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct WordsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandscapeNormalWordsView()
                .frame(width: 1000, height: 220)
                .attachEnv()

            LandscapeMiniWordsView()
                .frame(width: 1000, height: 220)
                .attachEnv()

            PortraitNormalWordsView()
                .frame(width: 220, height: 600)
                .attachEnv()

            PortraitMiniWordsView()
                .frame(width: 220, height: 600)
                .attachEnv()
        }
    }
}

struct AttachEnv: ViewModifier {
    let displayedWords = DisplayedWords(words: [
        ("known", "around", define("around")),
        ("unKnown", "andros", define("andros")),
        ("unKnown", "so", define("so")),
        ("known", "the", define("the")),
        ("known", "king", define("king")),
        ("known", "start", define("start")),
    ])
    let visualConfig = VisualConfig(
        fontSizeOfLandscape: 20,
        fontSizeOfPortrait: 13,
        colorOfLandscape: .orange,
        colorOfPortrait: .green,
        fontName: NSFont.systemFont(ofSize: 0.0).fontName
    )
    let smallConfig = SmallConfig(fontRate: 1.0, addLineBreak: true, isDisplayKnownWords: true)
    
    func body(content: Content) -> some View {
        content
            .environmentObject(displayedWords)
            .environmentObject(visualConfig)
            .environmentObject(smallConfig)
    }
}

extension View {
    func attachEnv() -> some View {
        self.modifier(AttachEnv())
    }
}

fileprivate func define(_ word: String) -> String {
    return DictionaryServices.define(word) ?? ""
}
