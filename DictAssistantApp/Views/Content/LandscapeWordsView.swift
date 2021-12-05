//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct LandscapeWordsView: View {
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue
    
    @EnvironmentObject var displayedWords: DisplayedWords
    @AppStorage(IsShowCurrentKnownKey) private var isShowCurrentKnown: Bool = false
    @AppStorage(IsShowCurrentKnownButWithOpacity0Key) private var isShowCurrentKnownButWithOpacity0: Bool = false
    @AppStorage(IsShowCurrentNotFoundWordsKey) private var isShowCurrentNotFoundWords: Bool = false

    var words: [WordCellWithId] {
        convertToWordCellWithId(
            from: displayedWords.wordCells,
            isShowCurrentKnown: isShowCurrentKnown,
            isShowCurrentKnownButWithOpacity0: isShowCurrentKnownButWithOpacity0,
            isShowCurrentNotFoundWords: isShowCurrentNotFoundWords)
    }
    
    var body: some View {
        switch LandscapeStyle(rawValue: landscapeStyle)! {
        case .normal, .autoScrolling:
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    BodyView(words: words, proxy: proxy)
                }
            }
        case .centered:
            CenteredView(words: words)
        }
    }
}

struct BodyView: View {
    let words: [WordCellWithId]

    let proxy: ScrollViewProxy?
    
    @AppStorage(LandscapeStyleKey) private var landscapeStyle: Int = LandscapeStyle.normal.rawValue

    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    var body: some View {
        HStack(alignment: .top) {
            ForEach(words) { wordCellWithId in
                SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
            }
            
            VStack { Spacer() }
        }
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
        .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
        .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
    }
}

struct CenteredView: View {
    let words: [WordCellWithId]
    
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                ForEach(words) { wordCellWithId in
                    SingleWordView(wordCell: wordCellWithId.wordCell).id(wordCellWithId.id)
                }
            }
            Spacer()
        }
        .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
        .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
    }
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
