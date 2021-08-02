//
//  PortraitWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

fileprivate struct OriginBody: View {
    @AppStorage(PortraitMaxHeightKey) private var portraitMaxHeight: Double = 200.0

    var body: some View {
        VStack(alignment: .leading) {
            WordsView()
                .frame(maxHeight: CGFloat(portraitMaxHeight), alignment: .topLeading)
        }
    }
}

fileprivate struct BackgroundVisualEffectBody: View {
    var body: some View {
        OriginBody().background(VisualEffectView(visualEffect: contentVisualEffect()))
    }
}

fileprivate struct BackgroundColorBody: View {
    @AppStorage(BackgroundColorKey) private var backgroundColor: Data = colorToData(NSColor.clear)!
    var theBackgroundColor: Color {
        Color(dataToColor(backgroundColor)!)
    }
    var body: some View {
        OriginBody()
            .background(theBackgroundColor)
    }
}

fileprivate struct WithBackgroundBody: View {
    @AppStorage(ContentBackgroundDisplayKey) private var contentBackgroundDisplay: Bool = false
    var body: some View {
        if contentBackgroundDisplay {
            BackgroundVisualEffectBody()
        } else {
            BackgroundColorBody()
        }
    }
}

fileprivate struct WithScrollViewBody: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            WithBackgroundBody()
        }
    }
}

struct PortraitWordsView: View {
    @AppStorage(PortraitCornerKey) private var portraitCorner: PortraitCorner = .topLeading
    var body: some View {
        switch portraitCorner {
        case .topLeading:
            HStack {
                WithScrollViewBody()
                Spacer()
            }
        case .topTrailing:
            HStack {
                Spacer()
                WithScrollViewBody()
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
