//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

let defaultMaxWidthOfLandscape: CGFloat = 300.0
let defaultMaxHeigthOfPortrait: CGFloat = 200.0

fileprivate struct SingleWordView: View {
    @Environment(\.addToKnownWords) var addToKnownWords
    @Environment(\.removeFromKnownWords) var removeFromKnownWords
    
    let taggedWordTrans: (String, String, String)
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    @Binding var displayKnownWords: Bool

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
    
    var body: some View {
        if tag == "unKnown" {
            (Text(word).foregroundColor(Color(color)).font(Font.custom(fontName, size: fontSize)) + Text(trans).foregroundColor(.white).font(Font.custom(fontName, size: fontSize * 0.9)))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                    Button("\(!displayKnownWords ? "Display" : "Hidden") current Known", action: { displayKnownWords.toggle() } )
                    Menu("Online Dict Link") {
                        Button("Collins", action: {
                            if isPhrase { return }
                            let url = URL(string: "https://www.collinsdictionary.com/dictionary/english/\(word)")
                            NSWorkspace.shared.open(url!)
                        })
                    }
                }
        } else {
            Text(word).foregroundColor(.gray).opacity( isPhrase ? 0.5 : 1)
                .font(Font.custom(fontName, size: fontSize))
                .padding(.all, 4)
                .contextMenu {
                    Button("Remove from Known", action: { removeFromKnownWords(word) })
                    Button("Hidden current Known", action: { displayKnownWords.toggle() } )
                }
        }
    }
}

fileprivate struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords

    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    
    @Binding var displayKnownWords: Bool
    
    var words: [(String, String, String)] {
        if displayKnownWords {
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
        if displayKnownWords {
            ForEach(Array(words.enumerated()), id: \.0) { _, taggedWordTrans in
                SingleWordView(
                    taggedWordTrans: taggedWordTrans,
                    color: color,
                    fontName: fontName,
                    fontSize: fontSize,
                    displayKnownWords: $displayKnownWords)
            }
        } else {
            ForEach(Array(words.filter { $0.0 == "unKnown" }.enumerated()), id: \.0) { _, taggedWordTrans in
                SingleWordView(
                    taggedWordTrans: taggedWordTrans,
                    color: color,
                    fontName: fontName,
                    fontSize: fontSize,
                    displayKnownWords: $displayKnownWords)
            }
        }
    }
}

struct LandscapeNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig

    @State var displayKnownWords: Bool = true

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                WordsView(
                    color: visualConfig.colorOfLandscape,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfLandscape,
                    displayKnownWords: $displayKnownWords
                )
                .frame(maxWidth: defaultMaxWidthOfLandscape, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .contextMenu {
            Button("\(!displayKnownWords ? "Display" : "Hidden") current Known", action: { displayKnownWords.toggle() } )
            Menu("MinimumTextHeight") {
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
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct LandscapeMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig
    @State var displayKnownWords: Bool = true

    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    WordsView(
                        color: visualConfig.colorOfLandscape,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfLandscape,
                        displayKnownWords: $displayKnownWords
                    )
                    .frame(maxWidth: defaultMaxWidthOfLandscape, maxHeight: .infinity, alignment: .topLeading)
                }
                .background(Color.black.opacity(0.75))
            }
            .contextMenu {
                Button("\(!displayKnownWords ? "Display" : "Hidden") current Known", action: { displayKnownWords.toggle() } )
                Menu("MinimumTextHeight") {
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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @State var displayKnownWords: Bool = false

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait,
                    displayKnownWords: $displayKnownWords
                )
                .frame(maxWidth: .infinity, maxHeight: defaultMaxHeigthOfPortrait, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @State var displayKnownWords: Bool = false

    var body: some View {
        HStack {
            Spacer()
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    WordsView(
                        color: visualConfig.colorOfPortrait,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfPortrait,
                        displayKnownWords: $displayKnownWords
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

fileprivate func say(word: String) {
    let task = Process()
    task.launchPath = "/usr/bin/say"
    var arguments = [String]();
    arguments.append(word)
    task.arguments = arguments
    task.launch()
}

struct WordsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LandscapeNormalWordsView()
                .frame(width: 1000, height: 220)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: [
                            ("known", "narrator", "..."),
                            ("unKnown", "Athenian", "...")]
                    ))
                .environmentObject(
                    VisualConfig(
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName
                        ))
            
            LandscapeMiniWordsView()
                .frame(width: 1000, height: 220)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: [
                            ("known", "narrator", "..."),
                            ("unKnown", "Athenian", "...")]
                    ))
                .environmentObject(
                    VisualConfig(
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName
                        ))
            
            PortraitNormalWordsView()
                .frame(width: 220, height: 600)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: [
                            ("known", "narrator", "..."),
                            ("unKnown", "Athenian", "...")]
                    ))
                .environmentObject(
                    VisualConfig(
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName
                        ))
            
            PortraitMiniWordsView()
                .frame(width: 220, height: 600)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: [
                            ("known", "narrator", "..."),
                            ("unKnown", "Athenian", "...")]
                    ))
                .environmentObject(
       
                    VisualConfig(
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName
                        ))
            
        }
    }
}

