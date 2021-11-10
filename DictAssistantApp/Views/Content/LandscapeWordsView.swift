//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct LandscapeWordsView: View {
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    
    var body: some View {
        switch LandscapeStyle(rawValue: landscapeStyle)! {
        case .normal, .autoScrolling:
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    BodyView(proxy: proxy)
                }
            }
        case .centered:
            BodyView(proxy: nil)
        }
    }
}

private struct BodyView: View {
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue

    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 160.0

    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    var words: [WordCellWithId] {
        convertToWordCellWithId(
            from: displayedWords.wordCells,
            isShowPhrase: isShowPhrase,
            isShowCurrentKnown: isShowCurrentKnown,
            isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0,
            isShowCurrentNotFoundWords: isShowCurrentNotFoundWords)
    }
    
    let proxy: ScrollViewProxy?
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(words) { wordCellWithId in
                SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
            }
        }
        .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
        .background(useContentBackgroundVisualEffect ?
                    VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                        nil)
        .onChange(of: words) { _ in
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(words.last?.id, anchor: .top)
            }
        }
        .onAppear {
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(words.last?.id, anchor: .top)
            }
        }
    }
    
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
