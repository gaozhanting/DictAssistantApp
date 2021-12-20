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

private struct BBBackground: ViewModifier {
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(useContentBackgroundVisualEffect ? nil : Color(dataToColor(backgroundColor)!))
            .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
    }
}
extension View {
    func bbBackground() -> some View {
        modifier(BBBackground())
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

private struct StandardPadding: ViewModifier {
    @AppStorage(DisplayStyleKey) var displayStyle: Int = DisplayStyle.standard.rawValue

    func body(content: Content) -> some View {
        switch DisplayStyle(rawValue: displayStyle)! {
        case .standard:
            content
                .padding()
        case .minimalist:
            content
        }
    }
}
extension View {
    func standardPadding() -> some View {
        modifier(StandardPadding())
    }
}

private struct StandardRR: ViewModifier {
    @AppStorage(DisplayStyleKey) var displayStyle: Int = DisplayStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) private var standardCornerRadius: Double = 10.0

    func body(content: Content) -> some View {
        switch DisplayStyle(rawValue: displayStyle)! {
        case .standard:
            content
                .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
        case .minimalist:
            content
        }
    }
}
extension View {
    func standardRR() -> some View {
        modifier(StandardRR())
    }
}

private struct StandardPaddingRR: ViewModifier {
    @AppStorage(DisplayStyleKey) var displayStyle: Int = DisplayStyle.standard.rawValue
    @AppStorage(StandardCornerRadiusKey) private var standardCornerRadius: Double = 10.0
    
    func body(content: Content) -> some View {
        switch DisplayStyle(rawValue: displayStyle)! {
        case .standard:
            content
                .uglyCP()
                .bbBackground()
                .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
        case .minimalist:
            content
                .bbBackground()
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
