//
//  DisplayStyleModifierView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/20.
//

import SwiftUI

private struct MinimalistPadding: ViewModifier {
    @AppStorage(DisplayStyleKey) var displayStyle: Int = DisplayStyle.standard.rawValue
    @AppStorage(MinimalistVPaddingKey) var minimalistVPadding: Double = 2.0
    @AppStorage(MinimalistHPaddingKey) var minimalistHPadding: Double = 6.0
    
    func body(content: Content) -> some View {
        switch DisplayStyle(rawValue: displayStyle)! {
        case .standard:
            content
        case .minimalist:
            content
                .padding(.vertical, minimalistVPadding)
                .padding(.horizontal, minimalistHPadding)
        }
    }
}
extension View {
    func minimalistPadding() -> some View {
        modifier(MinimalistPadding())
    }
}

private struct UglyConditionPadding: ViewModifier {
    @EnvironmentObject var displayedWords: DisplayedWords

    func body(content: Content) -> some View {
        if displayedWords.wordCells.isEmpty {
            content
        } else {
            content.padding()
        }
    }
}
extension View {
    func uglyCP() -> some View {
        modifier(UglyConditionPadding())
    }
}

private struct StandardPaddingRR: ViewModifier {
    @AppStorage(DisplayStyleKey) var displayStyle: Int = DisplayStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) private var standardCornerRadius: Double = 10.0

    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    func body(content: Content) -> some View {
        switch DisplayStyle(rawValue: displayStyle)! {
        case .standard:
            content
                .uglyCP()
                .background(useContentBackgroundVisualEffect ? nil : Color(dataToColor(backgroundColor)!))
                .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
                .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
        case .minimalist:
            content
                .background(useContentBackgroundVisualEffect ? nil : Color(dataToColor(backgroundColor)!))
                .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
        }
    }
}
extension View {
    func standardPaddingRR() -> some View {
        modifier(StandardPaddingRR())
    }
}

//struct DecorateView_Previews: PreviewProvider {
//    static var previews: some View {
//        DecorateView()
//    }
//}
