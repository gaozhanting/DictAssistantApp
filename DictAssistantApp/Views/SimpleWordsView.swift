//
//  SimpleWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

struct SimpleWordsView: View {
    @EnvironmentObject var visualConfig: VisualConfig
    @EnvironmentObject var recognizedText: RecognizedText
    @Environment(\.toggleContentPanelOpaque) var toggleContentPanelOpaque
    
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
            return .orange
        case .portrait:
            return .green
        }
    }
    
    var body: some View {
        ForEach(recognizedText.words, id: \.self) { word in
            (Text(word).foregroundColor(wordColor) + Text(translation(of: word)).foregroundColor(.white))
                .font(.system(size: fontSize))
                .padding(.all, 4)
                .onTapGesture {
                    toggleContentPanelOpaque()
                }
        }
        .layoutDirection(with: visualConfig.displayMode)
    }
}

struct LayoutDirection: ViewModifier {
    let displayMode: DisplayMode

    func body(content: Content) -> some View {
        switch displayMode {
        case .landscape:
            VStack {
                Spacer()
                ScrollView(.horizontal) {
                    HStack(alignment: .top) {
                        content
                            .frame(maxWidth: 190, maxHeight: .infinity, alignment: .topLeading)
                    }
                    .background(
                        Color.black
                            .opacity(0.55)
                    )
                }
            }

        case .portrait:
            HStack {
                Spacer()
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        content
                            .frame(maxHeight: 150, alignment: .topLeading)
                    }
                    .background(
                        Color.black
                            .opacity(0.75)
                    )
                }
            }
        }
    }
}

extension View {
    func layoutDirection(with displayMode: DisplayMode) -> some View {
        self.modifier(LayoutDirection(displayMode: displayMode))
    }
}

struct SimpleWordsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SimpleWordsView()
                .frame(width: 1000, height: 220)
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored, just a recommendations."]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .landscape, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            SimpleWordsView()
                .frame(width: 1000, height: 120)
                .environmentObject(RecognizedText(
                    texts: ["And this massively accelerated our leanring style"]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .landscape, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            SimpleWordsView()
                .frame(width: 1000, height: 220)
                .environmentObject(RecognizedText(
                    texts: [""]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .landscape, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            SimpleWordsView()
                .frame(width: 320, height: 500)
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            SimpleWordsView()
                .frame(width: 220, height: 500)
                .environmentObject(RecognizedText(
                    texts: ["A rectangle hovered here"]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
            SimpleWordsView()
                .frame(width: 220, height: 500)
                .environmentObject(RecognizedText(
                    texts: ["And this massively accelerated our leanring curve"]
                ))
                .environmentObject(VisualConfig(miniMode: false, displayMode: .portrait, fontSizeOfLandscape: 20, fontSizeOfPortrait: 13))
        }
    }
}

