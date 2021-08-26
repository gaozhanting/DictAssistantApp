//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

fileprivate struct OriginBody: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
    
    var body: some View {
        if portraitCorner == .bottomLeading {
            VStack(alignment: .leading) {
                HStack { Spacer() }
                WordsView()
                    .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .topLeading)
                HStack { Spacer() }
            }
            .rotationEffect(Angle(degrees: 180))
        } else {
            VStack(alignment: .leading) {
                WordsView()
                    .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .topLeading)
            }
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
            .background(portraitCorner == .bottomLeading ? nil : theBackgroundColor)
    }
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topTrailing
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
            BodyEmbeddedInScrollView()
                .rotationEffect(Angle(degrees: 180))
        }
    }
}

//
//struct PortraitWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        PortraitWordsView()
//    }
//}
