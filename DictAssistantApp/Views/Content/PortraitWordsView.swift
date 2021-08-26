//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

fileprivate struct OriginBody: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0
    
    var body: some View {
        VStack(alignment: .leading) {
            WordsView()
                .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .topLeading)
        }
    }
}

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

fileprivate struct BodyWithVisualEffectBackground: View {
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    var body: some View {
        OriginBody()
            .background(
                VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!)
                    .preferredColorScheme(toSystemColorScheme(from: theColorScheme))
            )
    }
}

fileprivate struct BodyWithColorBackground: View {
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
    }
    var body: some View {
        OriginBody()
            .background(theBackgroundColor)
    }
}

fileprivate struct BodyWithBackground: View {
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    var body: some View {
        if contentBackgroundVisualEffect {
            BodyWithVisualEffectBackground()
        } else {
            BodyWithColorBackground()
        }
    }
}

fileprivate struct BodyEmbeddedInScrollView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            BodyWithBackground()
        }
    }
}

fileprivate struct PortraitBottomLeadingView: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    var body: some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        ForEach(words) { wordCellWithId in
                            SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                        }
                        .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)

                        HStack { Spacer() }
                    }
                    .background(contentBackgroundVisualEffect ?
                                    VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!).preferredColorScheme(toSystemColorScheme(from: theColorScheme)) :
                                    nil)
                    .frame(minHeight: reader.size.height, alignment: .bottomLeading) // key point
                }
                .onChange(of: words) { _ in
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
                .onAppear {
                    proxy.scrollTo(words.last?.id, anchor: .top)
                }
            }
        }
    }
    
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowPhrasesKey) private var isShowPhrase: Bool = true // the value only used when the key doesn't exists, this will never be the case because we init it when app lanched
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    
    var words: [WordCellWithId] {
        convertToWordCellWithId(from: displayedWords.wordCells, isShowPhrase: isShowPhrase, isShowCurrentKnown: isShowCurrentKnown)
    }
}

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    var body: some View {
        switch portraitCorner {
        case .topTrailing:
            HStack {
                Spacer()
                BodyEmbeddedInScrollView()
            }
        case .topLeading:
            HStack {
                BodyEmbeddedInScrollView()
                Spacer()
            }
        case .bottomLeading:
            PortraitBottomLeadingView()
        }
    }
}

//
//struct PortraitWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortraitWordsView()
//    }
//}
