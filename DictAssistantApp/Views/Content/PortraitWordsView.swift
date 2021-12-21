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
                    .standardPaddingRR()
                }
            }
        case .topLeading:
            HStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        WordsView()
                            .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    }
                    .standardPaddingRR()
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
                        .padding()
                        .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .leading)
                    
                    HStack { Spacer() }
                }
                .standardPaddingRR()
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
                .standardPaddingRR()
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
