//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

fileprivate struct OriginBody: View {
    @AppStorage(LandscapeMaxWidthKey) private var landscapeMaxWidth: Double = 260.0

    var body: some View {
        WordsView()
            .frame(maxWidth: CGFloat(landscapeMaxWidth),
//                   maxHeight: defaultMaxHeighOfLandscape,
                   alignment: .topLeading)
    }
}

fileprivate struct WithScrollViewBody: View {
    @AppStorage(ContentBackgroundVisualEffectKey) private var contentBackgroundVisualEffect: Bool = false
    
    @AppStorage(TheColorSchemeKey) private var theColorScheme: TheColorScheme = .system
    @AppStorage(ContentBackGroundVisualEffectMaterialKey) private var contentBackGroundVisualEffectMaterial: Int = NSVisualEffectView.Material.titlebar.rawValue

    var body: some View {
        if contentBackgroundVisualEffect {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    OriginBody()
                    VStack { Spacer() }
                }
                .background(
                    VisualEffectView(material: NSVisualEffectView.Material(rawValue: contentBackGroundVisualEffectMaterial)!)
                        .preferredColorScheme(toSystemColorScheme(from: theColorScheme))
                ) // Visual effect mess up when attach mutiple seperate word
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    OriginBody()
                    VStack { Spacer() }
                }
            }
        }
    }
}

struct LandscapeWordsView: View {
    var body: some View {
        WithScrollViewBody()
    }
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
