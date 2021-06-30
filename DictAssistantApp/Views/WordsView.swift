//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

fileprivate func translation(of word: String) -> String {
    if let tr = DictionaryServices.define(word) {
        return tr
    } else {
        return ""
    }
}

fileprivate func translationOneline(of word: String) -> String {
    if let tr = DictionaryServices.define(word) {
        return tr.replacingOccurrences(of: "\n", with: " ")
    } else {
        return ""
    }
}

fileprivate struct OnelineWordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords

    @Environment(\.addToKnownWords) var addToKnownWords
    
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    
    var body: some View {
        ForEach(displayedWords.words, id: \.self) { word in
            (Text(word).foregroundColor(Color(color)) + Text(translationOneline(of: word)).foregroundColor(.white))
                .lineLimit(1)
                .font(Font.custom(fontName, size: fontSize))
//                .padding(.all, 4)
                .padding(.horizontal, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                }
        }
    }
}

struct PortraitOnelineWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                OnelineWordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait
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
                    OnelineWordsView(
                        color: visualConfig.colorOfPortrait,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfPortrait
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


fileprivate struct WordsView: View {
    @EnvironmentObject var displayedWords: DisplayedWords

    @Environment(\.addToKnownWords) var addToKnownWords
    
    let color: NSColor
    let fontName: String
    let fontSize: CGFloat
    
    var body: some View {
        ForEach(displayedWords.words, id: \.self) { word in
            (Text(word).foregroundColor(Color(color)) + Text(translation(of: word)).foregroundColor(.white))
                .font(Font.custom(fontName, size: fontSize))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                }
        }
    }
}

struct LandscapeNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                WordsView(
                    color: visualConfig.colorOfLandscape,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfLandscape
                )
                .frame(maxWidth: 190, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.opacity(0.75))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        
    }
}

struct LandscapeMiniWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    WordsView(
                        color: visualConfig.colorOfLandscape,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfLandscape
                    )
                    .frame(maxWidth: 190, maxHeight: .infinity, alignment: .topLeading)
                }
                .background(Color.black.opacity(0.75))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitNormalWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                WordsView(
                    color: visualConfig.colorOfPortrait,
                    fontName: visualConfig.fontName,
                    fontSize: visualConfig.fontSizeOfPortrait
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

    var body: some View {
        HStack {
            Spacer()
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    WordsView(
                        color: visualConfig.colorOfPortrait,
                        fontName: visualConfig.fontName,
                        fontSize: visualConfig.fontSizeOfPortrait
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
                        words: ["someone", "like", "you"]))
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
                        words: ["someone", "like", "you"]))
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
                        words: ["someone"]))
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
                        words: ["someone"]))
                .environmentObject(
                    VisualConfig(
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName
                        ))
            
            PortraitOnelineWordsView()
                .frame(width: 420, height: 500)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: ["someone", "somebody"]))
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
                        words: ["someone", "somebody"]))
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

