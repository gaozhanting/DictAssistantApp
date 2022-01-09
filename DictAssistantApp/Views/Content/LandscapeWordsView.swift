//
//  LandscapeWordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/27.
//

import SwiftUI

struct LandscapeWordsView: View {
    @AppStorage(ContentPaddingStyleKey) var contentPaddingStyle: Int = ContentPaddingStyle.standard.rawValue
    
    var body: some View {
        switch ContentPaddingStyle(rawValue: contentPaddingStyle)! {
        case .minimalist:
            LandscapeWordsView1()
        case .standard:
            LandscapeWordsView2()
        }
    }
}

struct LandscapeWordsView1: View {
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault

    var body: some View {
        switch LandscapeStyle(rawValue: landscapeStyle)! {
        case .normal, .autoScrolling:
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    BodyView1(proxy: proxy)
                }
            }
        case .centered:
            CenteredView()
        }
    }
}

struct LandscapeWordsView2: View {
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    
    var body: some View {
        switch LandscapeStyle(rawValue: landscapeStyle)! {
        case .normal, .autoScrolling:
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    BodyView2(proxy: proxy)
                }
            }
        case .centered:
            CenteredView()
        }
    }
}

private struct BodyView1: View {
    @EnvironmentObject var displayedWords: DisplayedWords

    let proxy: ScrollViewProxy?

    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault

    var body: some View {
        HStack(alignment: .top) {
            WordsView()

            VStack { Spacer() }
        }
        .bbBackground()
        .onChange(of: displayedWords.wordCells) { _ in
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(displayedWords.wordCells.last?.id, anchor: .top)
            }
        }
        .onAppear {
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(displayedWords.wordCells.last?.id, anchor: .top)
            }
        }
    }
}

private struct BodyView2: View {
    @EnvironmentObject var displayedWords: DisplayedWords
    
    let proxy: ScrollViewProxy?
    
    @AppStorage(LandscapeStyleKey) var landscapeStyle: Int = LandscapeStyleDefault
    
    var body: some View {
        HStack(alignment: .top) {
            WordsView()
            
            VStack { Spacer() }
        }
        .paddingAndBackground() // shrink bug, don't known why; so minimalist need use .bbBackground(), only here diff
        .onChange(of: displayedWords.wordCells) { _ in
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(displayedWords.wordCells.last?.id, anchor: .top)
            }
        }
        .onAppear {
            if LandscapeStyle(rawValue: landscapeStyle) == .autoScrolling {
                proxy?.scrollTo(displayedWords.wordCells.last?.id, anchor: .top)
            }
        }
    }
}

private struct CenteredView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                WordsView()
            }
            
            Spacer()
        }
        .paddingAndBackground()
    }
}

//struct LandscapeWordsView_Previews: PreviewProvider {
//    static var previews: some View {
//        LandscapeWordsView()
//    }
//}
