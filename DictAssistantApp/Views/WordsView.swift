//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

//fileprivate func translation(of word: String) -> String? {
//    return DictionaryServices.define(word)
////    if let tr = DictionaryServices.define(word) {
////        return tr
////    } else {
////        return ""
////    }
//}
//
//fileprivate func translationOneline(of word: String) -> String {
//    if let tr = DictionaryServices.define(word) {
//        return tr.replacingOccurrences(of: "\n", with: " ")
//    } else {
//        return ""
//    }
//}
//
//fileprivate struct OnelineWordsView: View {
//    @EnvironmentObject var displayedWords: DisplayedWords
//
//    @Environment(\.addToKnownWords) var addToKnownWords
//
//    let color: NSColor
//    let fontName: String
//    let fontSize: CGFloat
//
//    var body: some View {
//        ForEach(displayedWords.words, id: \.self) { word in
//            (Text(word).foregroundColor(Color(color)) + Text(translationOneline(of: word)).foregroundColor(.white))
//                .lineLimit(1)
//                .font(Font.custom(fontName, size: fontSize))
//                .padding(.horizontal, 4)
//                .contextMenu {
//                    Button("Add to Known", action: { addToKnownWords(word) })
//                }
//        }
//    }
//}

struct PortraitOnelineNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait,
                    displayKnownWords: Binding.constant(true)
                )
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitOnelineMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    WordsView(
                        color: visualConfig.colorOfPortrait,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfPortrait,
                        displayKnownWords: Binding.constant(true)
                    )
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .background(Color.black.opacity(0.75))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

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
            (Text(word).foregroundColor(Color(color)) + Text(trans).foregroundColor(.white))
                .font(Font.custom(fontName, size: fontSize))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                    Button("\(!displayKnownWords ? "Display" : "Hidden") current Known", action: { displayKnownWords.toggle() } )
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
//                    .id(index)
            }
        } else {
            ForEach(Array(words.filter { $0.0 == "unKnown" }.enumerated()), id: \.0) { _, taggedWordTrans in
                SingleWordView(
                    taggedWordTrans: taggedWordTrans,
                    color: color,
                    fontName: fontName,
                    fontSize: fontSize,
                    displayKnownWords: $displayKnownWords)
//                    .id(index)
            }
        }
    }
}

struct LandscapeNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var textProcessConfig: TextProcessConfig
//    @EnvironmentObject var displayedWords: DisplayedWords

    @State var displayKnownWords: Bool = true
    
//    var lastIndex: Int {
//        if displayKnownWords {
//            return displayedWords.words.count
//        } else {
//            return displayedWords.words.filter { $0.0 == "unknown" }.count
//        }
//    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    WordsView(
                        color: visualConfig.colorOfLandscape,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfLandscape,
                        displayKnownWords: $displayKnownWords
                    )
                    .frame(maxWidth: 300, maxHeight: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
//            .onChange(of: displayedWords.words.count) { newCount in
////                proxy.scrollTo(newCount-1, anchor: .top)
//            }
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
                    .frame(maxWidth: 300, maxHeight: .infinity, alignment: .topLeading)
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
                .frame(maxWidth: .infinity, maxHeight: 150, alignment: .topLeading)
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
                    .frame(maxHeight: 150, alignment: .topLeading)
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
            
            PortraitOnelineNormalWordsView()
                .frame(width: 420, height: 500)
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
            
            PortraitOnelineMiniWordsView()
                .frame(width: 420, height: 500)
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

