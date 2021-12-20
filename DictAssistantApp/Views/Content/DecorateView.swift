//
//  DecorateView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/20.
//

import SwiftUI

struct Decorate: ViewModifier {
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.windowBackgroundColor)!
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue
    @AppStorage(UseContentBackgroundVisualEffectKey) private var useContentBackgroundVisualEffect: Bool = false
    @AppStorage(ContentCornerRadiusKey) private var contentCornerRadius: Double = 10.0
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(useContentBackgroundVisualEffect ? nil : Color(dataToColor(backgroundColor)!))
            .background(useContentBackgroundVisualEffect ? VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!) : nil)
            .clipShape(RoundedRectangle(cornerRadius: contentCornerRadius))
    }
}

extension View {
    func decorate() -> some View {
        modifier(Decorate())
    }
}

//struct DecorateView_Previews: PreviewProvider {
//    static var previews: some View {
//        DecorateView()
//    }
//}
