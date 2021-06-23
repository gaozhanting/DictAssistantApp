//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

struct WordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var displayedWords: DisplayedWords

    @Environment(\.closeContentPanel) var closeContentPanel
    @Environment(\.showContentPanel) var showContentPanel
    
    @Environment(\.addToFamiliars) var addToFamiliars
    
    func translation(of word: String) -> String {
        if let tr = DictionaryServices.define(word) {
            return tr
        } else {
            return ""
        }
    }

    var fontSize: CGFloat {
        switch visualConfig.displayMode {
        case .landscape:
            return visualConfig.fontSizeOfLandscape
        case .portrait:
            return visualConfig.fontSizeOfPortrait
        }
    }
    
    var wordColor: Color {
        switch visualConfig.displayMode {
        case .landscape:
            return Color(visualConfig.colorOfLandscape)
        case .portrait:
            return Color(visualConfig.colorOfPortrait)
        }
    }
    
    var wordsView: some View {
        ForEach(displayedWords.words, id: \.self) { word in
            (Text(word).foregroundColor(wordColor) + Text(translation(of: word)).foregroundColor(.white))
                .font(Font.custom(visualConfig.fontName, size: fontSize))
                .padding(.all, 4)
                .contextMenu {
                    Button("Add to familiars", action: { addToFamiliars(word) })
                }
//                .onLongPressGesture { // todo: double click (intentional, no accidental)
//                    say(word: word)
//                }
        }
    }
    
    var body: some View {
        switch visualConfig.displayMode {
        case .landscape:
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
                                .opacity(0.55)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()

        case .portrait:
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
//            WordsView()
//                .frame(width: 1000, height: 220)
//                .environmentObject(RecognizedText(
//                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored, just a recommendations."]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniModeInner: false,
//                        displayModeInner: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName,
//                        cropperStyleInner: .rectangle,
//                        setSideEffectCode: {}
//                        ))
//
//            WordsView()
//                .frame(width: 200, height: 720)
//                .environmentObject(RecognizedText(
//                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored, just a recommendations."]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniModeInner: false,
//                        displayModeInner: .portrait,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName,
//                        cropperStyleInner: .rectangle,
//                        setSideEffectCode: {}
//                        ))
            
//            WordsView()
//                .frame(width: 1000, height: 120)
//                .environmentObject(RecognizedText(
//                    texts: ["And this massively accelerated our leanring style"]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//
//            WordsView()
//                .frame(width: 1000, height: 220)
//                .environmentObject(RecognizedText(
//                    texts: [""]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//
//            WordsView()
//                .frame(width: 320, height: 500)
//                .environmentObject(RecognizedText(
//                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored"]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//
//            WordsView()
//                .frame(width: 220, height: 500)
//                .environmentObject(RecognizedText(
//                    texts: ["A rectangle hovered here"]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
//
//            WordsView()
//                .frame(width: 220, height: 500)
//                .environmentObject(RecognizedText(
//                    texts: ["And this massively accelerated our leanring curve"]
//                ))
//                .environmentObject(
//                    VisualConfig(
//                        miniMode: false,
//                        displayMode: .landscape,
//                        fontSizeOfLandscape: 20,
//                        fontSizeOfPortrait: 13,
//                        colorOfLandscape: .orange,
//                        colorOfPortrait: .green,
//                        fontName: NSFont.systemFont(ofSize: 0.0).fontName))
            
        }
    }
}

