//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

func toSystemColorScheme(from theColorScheme: TheColorScheme) -> ColorScheme? {
    switch theColorScheme {
    case .light:
        return .light
    case .dark:
        return .dark
    case .system:
        return nil
    }
}

fileprivate struct BodyView: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0

    @AppStorage(ContentBackgroundColorKey) private var contentBackgroundColor: Bool = true
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                WordsView()
                    .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .topLeading)
            }
            .background(contentBackgroundColor ? Color(dataToColor(backgroundColor)!): nil)
            .background(contentBackgroundVisualEffect ?
                        VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!)
                            .preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                            nil)
        }
    }
}

fileprivate struct PortraitBottomLeadingViewTwoRotation: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    @AppStorage(ContentBackgroundColorKey) private var contentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    var words: [WordCellWithId] {
        convertToWordCellWithId(
            from: displayedWords.wordCells,
            isShowPhrase: isShowPhrase,
            isShowCurrentKnown: isShowCurrentKnown,
            isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0,
            isShowCurrentNotFoundWords: isShowCurrentNotFoundWords)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(words) { wordCellWithId in
                    SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: .identity
                ))
                .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                
                HStack { Spacer() }
            }
            .rotationEffect(Angle(degrees: 180))
            .background(contentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
            .background(contentBackgroundVisualEffect ?
                        VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                            nil)
        }
        .rotationEffect(Angle(degrees: 180))
    }
    
}

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    var body: some View {
        switch portraitCorner {
        case .topTrailing:
            HStack {
                Spacer()
                BodyView()
            }
        case .topLeading:
            HStack {
                BodyView()
                Spacer()
            }
        case .bottomLeading:
            PortraitBottomLeadingViewTwoRotation()
        }
    }
}

//
//struct PortraitWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortraitWordsView()
//    }
//}
