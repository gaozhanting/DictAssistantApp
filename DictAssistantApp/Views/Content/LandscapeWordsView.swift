//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct LandscapeWordsView: View {
    var body: some View {
        LandscapeWordsViewAutoScroll()
    }
}

struct LandscapeWordsViewAutoScroll: View {
    var body: some View {
        ScrollViewReader { proxy in
            BodyView(proxy: proxy)
        }
    }
}

fileprivate struct BodyView: View {
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue

    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0

    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrases: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    var words: [WordCellWithId] {
        convertToWordCellWithId(
            from: displayedWords.wordCells,
            isShowPhrases: isShowPhrases,
            isShowCurrentKnown: isShowCurrentKnown,
            isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0,
            isShowCurrentNotFoundWords: isShowCurrentNotFoundWords)
    }
    
    let proxy: ScrollViewProxy
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(words) { wordCellWithId in
                    SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                }
                .frame(maxWidth: CGFloat(landscapeMaxWidth))
            }
            .background(contentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
            .background(contentBackgroundVisualEffect ?
                            VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                            nil)
            .onChange(of: words) { _ in
                if landscapeAutoScroll {
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
            }
            .onAppear {
                if landscapeAutoScroll {
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
            }
        }
    }
    
    @AppStorage(ContentBackgroundColorKey) private var contentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(LandscapeAutoScrollKey) private var landscapeAutoScroll: Bool = true
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
