//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

fileprivate let defaultMaxWidthOfLandscape: CGFloat = 260.0
fileprivate let defaultMaxHeighOfLandscape: CGFloat = 120.0 // why Text can't auto adjust height?

fileprivate struct OriginBody: View {
    var body: some View {
        WordsView()
            .frame(maxWidth: defaultMaxWidthOfLandscape, maxHeight: defaultMaxHeighOfLandscape, alignment: .topLeading)
    }
}

fileprivate struct WithScrollViewBody: View {
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
    }
    
    var body: some View {
        if contentBackgroundDisplay {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    OriginBody()
                }
                .background(VisualEffectView(visualEffect: contentVisualEffect())) // Visual effect mess up when attach mutiple seperate word
            }
            .padding(.vertical, 10)
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top) {
                    OriginBody()
                        .background(theBackgroundColor)
                }
            }
            .padding(.vertical, 10)
        }
    }
}

struct LandscapeWordsView: View {
    @AppStorage(LandscapeCornerKey) private var landscapeCorner: LandscapeCorner = .topLeading

    var body: some View {
        switch landscapeCorner {
        case .topLeading:
            VStack {
                WithScrollViewBody()
                Spacer()
            }

        case .bottomLeading:
            VStack {
                Spacer()
                WithScrollViewBody()
            }
        }
    }
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
