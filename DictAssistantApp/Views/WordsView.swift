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

struct LandscapeWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var displayedWords: DisplayedWords

    @Environment(\.addToKnownWords) var addToKnownWords
    
    var wordsView: some View {
        ForEach(displayedWords.words, id: \.self) { word in
            (Text(word).foregroundColor(Color(visualConfig.colorOfLandscape)) + Text(translation(of: word)).foregroundColor(.white))
                .font(Font.custom(visualConfig.fontName, size: visualConfig.fontSizeOfLandscape))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                }
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        wordsView
                            .frame(maxWidth: 190, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .background(
                        Color.black
                            .opacity(0.75)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

struct PortraitWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var displayedWords: DisplayedWords

    @Environment(\.addToKnownWords) var addToKnownWords
    
    var wordsView: some View {
        ForEach(displayedWords.words, id: \.self) { word in
            (Text(word).foregroundColor(Color(visualConfig.colorOfPortrait)) + Text(translation(of: word)).foregroundColor(.white))
                .font(Font.custom(visualConfig.fontName, size: visualConfig.fontSizeOfPortrait))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to Known", action: { addToKnownWords(word) })
                }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        wordsView
                            .frame(maxHeight: 150, alignment: .topLeading)
                    }
                    .background(
                        Color.black
                            .opacity(0.75)
                    )
                }
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
            LandscapeWordsView()
                .frame(width: 1000, height: 220)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: ["someone", "like", "you"]))
                .environmentObject(
                    VisualConfig(
                        miniModeInner: false,
                        displayModeInner: .landscape,
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName,
                        cropperStyleInner: .rectangle,
                        setSideEffectCode: {},
                        switchWordsPanel: {}
                        ))
            
            PortraitWordsView()
                .frame(width: 220, height: 1000)
                .environment(\.addToKnownWords, {_ in })
                .environmentObject(
                    DisplayedWords(
                        words: ["someone", "like", "you"]))
                .environmentObject(
                    VisualConfig(
                        miniModeInner: false,
                        displayModeInner: .portrait,
                        fontSizeOfLandscape: 20,
                        fontSizeOfPortrait: 13,
                        colorOfLandscape: .orange,
                        colorOfPortrait: .green,
                        fontName: NSFont.systemFont(ofSize: 0.0).fontName,
                        cropperStyleInner: .rectangle,
                        setSideEffectCode: {},
                        switchWordsPanel: {}
                        ))
        }
    }
}

