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
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false

    var body: some View {
        if contentBackgroundDisplay {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    OriginBody()
                    VStack { Spacer() }
                }
                .background(VisualEffectView(visualEffect: contentVisualEffect())) // Visual effect mess up when attach mutiple seperate word
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
