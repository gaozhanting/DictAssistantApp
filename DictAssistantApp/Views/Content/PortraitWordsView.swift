//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) private var portraitCorner: Int = PortraitCorner.topTrailing.rawValue
    var body: some View {
        switch PortraitCorner(rawValue: portraitCorner)! {
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

fileprivate struct BodyView: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0

    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                WordsView()
                    .frame(maxHeight: CGFloat(portraitMaxHeight))
            }
            .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!): nil)
            .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
        }
    }
}

fileprivate struct PortraitBottomLeadingViewTwoRotation: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 100.0
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    @AppStorage(UseContentBackgroundColorKey) private var useContentBackgroundColor: Bool = true
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading) {
                WordsView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .identity
                    ))
                    .frame(maxHeight: CGFloat(portraitMaxHeight))
                
                HStack { Spacer() }
            }
            .rotationEffect(Angle(degrees: 180))
            .background(useContentBackgroundColor ? Color(dataToColor(backgroundColor)!) : nil)
            .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
        }
        .rotationEffect(Angle(degrees: 180))
    }
    
}

//
//struct PortraitWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortraitWordsView()
//    }
//}
