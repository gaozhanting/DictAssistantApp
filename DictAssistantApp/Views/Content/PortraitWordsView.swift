//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    var body: some View {
        switch PortraitCorner(rawValue: portraitCorner)! {
        case .topTrailing:
            HStack {
                Spacer()
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WordsView()
                            .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    }
                    .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!): nil)
                    .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
                }
            }
        case .topLeading:
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WordsView()
                            .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    }
                    .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!): nil)
                    .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
                }
                Spacer()
            }
        case .bottomLeading:
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    WordsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .identity
                        ))
                        .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    
                    HStack { Spacer() }
                }
                .rotationEffect(Angle(degrees: 180))
                .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
                .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
            }
            .rotationEffect(Angle(degrees: 180))
        case .top:
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    WordsView()
                        .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    
                    HStack { Spacer() } // only this works
                }
                .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!): nil)
                .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
            }
        }
    }
}

//
//struct PortraitWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortraitWordsView()
//    }
//}
