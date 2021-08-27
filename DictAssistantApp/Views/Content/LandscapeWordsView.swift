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
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    ForEach(words) { wordCellWithId in
                        SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                    }
                    .frame(maxWidth: CGFloat(landscapeMaxWidth))
                }
                .background(contentBackgroundVisualEffect ?
                                VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                                nil)
                .onChange(of: words) { _ in
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
                .onAppear {
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
            }
        }
    }
    
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 260.0

    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var words: [WordCellWithId] {
        convertToWordCellWithId(from: displayedWords.wordCells, isShowPhrase: isShowPhrase, isShowCurrentKnown: isShowCurrentKnown)
    }
}

struct LandscapeWordsViewTwoRotation: View {
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top) {
                ForEach(words) { wordCellWithId in
                    SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                }
                .frame(maxWidth: CGFloat(landscapeMaxWidth))
            }
            .rotationEffect(Angle(degrees: 180))
            .background(contentBackgroundVisualEffect ?
                            VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                            nil)
        }
        .rotationEffect(Angle(degrees: 180))
    }
    
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 260.0

    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var words: [WordCellWithId] {
        convertToWordCellWithId(from: displayedWords.wordCells, isShowPhrase: isShowPhrase, isShowCurrentKnown: isShowCurrentKnown)
    }
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
