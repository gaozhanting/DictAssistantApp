//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) var portraitCorner: Int = PortraitCornerDefault
    @AppStorage(PortraitMaxHeightKey) var portraitMaxHeight: Double = PortraitMaxHeightDefault
    
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
                    .paddingAndBackground()
                }
            }
        case .topLeading:
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WordsView()
                            .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    }
                    .paddingAndBackground()
                }
                Spacer()
            }
        case .bottom:
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
                .paddingAndBackground()
                .rotationEffect(Angle(degrees: 180))
            }
            .rotationEffect(Angle(degrees: 180))
        case .top:
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    WordsView()
                        .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    
                    HStack { Spacer() } // only this works
                }
                .paddingAndBackground()
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
