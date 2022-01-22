//
//  PaddingAndBackground.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/20.
//

import SwiftUI

private struct BBBackground: ViewModifier {
    @AppStorage(BackgroundColorKey) var backgroundColor: Data = BackgroundColorDefault
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) var useContentBackgroundVisualEffect: Bool = false
    
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
    var isEmpty: Bool {
        displayedWords.wordCells.isEmpty
    }

    func body(content: Content) -> some View {
        content.padding(.all, isEmpty ? 0 : nil) //  If you set the value to nil, SwiftUI uses the system-default amount. The default is nil.
    }
}
extension View {
    func uglyCP() -> some View {
        modifier(UglyConditionPadding())
    }
}

private struct PaddingAndBackground: ViewModifier {
    @AppStorage(IsShowContentFrameKey) var isShowContentFrame: Bool = true

    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    
    func body(content: Content) -> some View {
        switch ContentPaddingStyle(rawValue: contentPaddingStyle)! {
        case .standard:
            if isShowContentFrame {
                content
            } else {
                content
                    .uglyCP()
                    .bbBackground()
                    .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
            }
        case .minimalist:
            if isShowContentFrame {
                content
            } else {
                content
                    .bbBackground()
                    .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
            }
        }
    }
}

extension View {
    func paddingAndBackground() -> some View {
        modifier(PaddingAndBackground())
    }
}

private struct PaddingAndBackground2: ViewModifier {
    @AppStorage(IsShowContentFrameKey) var isShowContentFrame: Bool = true

    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    
    func body(content: Content) -> some View {
        switch ContentPaddingStyle(rawValue: contentPaddingStyle)! {
        case .standard:
            if isShowContentFrame {
                content
                    .uglyCP()
                    .bbBackground()
                    .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
            } else {
                content
            }
        case .minimalist:
            if isShowContentFrame {
                content
                    .bbBackground()
                    .clipShape(RoundedRectangle(cornerRadius: standardCornerRadius))
            } else {
                content
            }
        }
    }
}

extension View {
    func paddingAndBackground2() -> some View {
        modifier(PaddingAndBackground2())
    }
}
