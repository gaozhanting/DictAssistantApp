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
    
    func translation(of word: String) -> String {
        if let tr = DictionaryServices.define(word) {
            return tr
        } else {
            return ""
        }
    }
    
    var body: some View {
        ForEach(recognizedText.words, id: \.self) { word in
            (Text(word).foregroundColor(.orange) + Text(translation(of: word)).foregroundColor(.white))
                .font(.system(size: 20))
                .onTapGesture {
                    openDict(word)
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
            ScrollView(.horizontal) {
                HStack(alignment: .top) {
                    content
                        .frame(width: 130, alignment: .topLeading)
                }
                .padding(.leading, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.75))
        case .portrait:
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    content
                        .frame(maxHeight: 150, alignment: .topLeading)
                }
                .padding(.top, 7)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.75))
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
                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .environmentObject(VisualConfig(displayMode: .landscape))
            SimpleWordsView()
                .frame(width: 220, height: 1000)
                .environmentObject(RecognizedText(
                    texts: ["Tomorrow - A shift mystical land where 99% of all human productivity, motivation and achievement are stored"]
                ))
                .environmentObject(VisualConfig(displayMode: .portrait))
        }
    }
}
