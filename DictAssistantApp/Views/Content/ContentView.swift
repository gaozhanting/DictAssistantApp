//
//  WordsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/7.
//

import SwiftUI
import DataBases

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage(TheColorSchemeKey) private var theColorScheme: Int = TheColorScheme.system.rawValue
    
    var body: some View {
        ContentModeView()
            .environment(\.colorScheme, toSystemColorScheme(from: theColorScheme, with: colorScheme))
    }
}

private func toSystemColorScheme(from theColorScheme: Int, with systemColorScheme: ColorScheme) -> ColorScheme {
    switch TheColorScheme(rawValue: theColorScheme)! {
    case .light:
        return .light
    case .dark:
        return .dark
    case .system:
        return systemColorScheme
    case .systemReversed:
        switch systemColorScheme {
        case .light:
            return .dark
        case .dark:
            return .light
        @unknown default:
            return systemColorScheme // this logic is wrong, but currently not execute
        }
    }
}

private struct ContentModeView: View {
    @AppStorage(ContentStyleKey) private var contentStyle: Int = ContentStyle.portrait.rawValue

    var body: some View {
        switch ContentStyle(rawValue: contentStyle)! {
        case .portrait:
            PortraitWordsView()
        case .landscape:
            LandscapeWordsView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static func define(_ word: String) -> String {
//        return appleDefine(word) ?? ""
        return mixDefine(word) ?? ""
    }
    
    static func sampleWords(_ words: [String]) -> DisplayedWords {
        DisplayedWords(wordCells: words.map { word in
            WordCell(word: word, isKnown: .unKnown, trans: define(word))
        })
    }
    
    static let displayedWords = DisplayedWords(wordCells: [
        WordCell(word: "around", isKnown: .known, trans: ""),
//        WordCell(word: "andros", isKnown: .unKnown, trans: define("andros")),
        WordCell(word: "the", isKnown: .known, trans: ""),
        WordCell(word: "king", isKnown: .known, trans: ""),
//        WordCell(word: "gotten", isKnown: .unKnown, trans: define("gotten")),
//        WordCell(word: "grant", isKnown: .unKnown, trans: define("grant")),
//        WordCell(word: "made", isKnown: .unKnown, trans: define("made")),
//        WordCell(word: "make it", isKnown: .unKnown, trans: define("make it")),
//        WordCell(word: "handle", isKnown: .unKnown, trans: define("handle")),
//        WordCell(word: "beauty", isKnown: .unKnown, trans: define("beauty")),
//        WordCell(word: "butcher", isKnown: .unKnown, trans: define("butcher")),
        
//        WordCell(word: "effort", isKnown: .unKnown, trans: define("effort")),
//        WordCell(word: "instilled", isKnown: .unKnown, trans: define("instilled")),
//        WordCell(word: "instilled", isKnown: .unKnown, trans: define("instilled")),
        
        
//        WordCell(word: "fierce", isKnown: .unKnown, trans: define("fierce")),
        WordCell(word: "man", isKnown: .unKnown, trans: define("man")),
        WordCell(word: "Dish", isKnown: .unKnown, trans: define("Dish")),
        WordCell(word: "superstitious", isKnown: .unKnown, trans: define("superstitious")),

        WordCell(word: "and", isKnown: .known, trans: ""),
//        WordCell(word: "recipe", isKnown: .unKnown, trans: define("recipe")),

//        WordCell(word: "make up one's mind", isKnown: .unKnown, trans: define("make up one's mind")),

    ])
    
    static let displayedWords2 = DisplayedWords(wordCells: [
        WordCell(word: "contemporary", isKnown: .unKnown, trans: define("contemporary")),
        WordCell(word: "local government", isKnown: .unKnown, trans: define("local government")),
    ])
    
    static let displayedWords3 = DisplayedWords(wordCells: [
        WordCell(word: "modern history", isKnown: .unKnown, trans: define("modern history")),
        WordCell(word: "contemporary", isKnown: .unKnown, trans: define("contemporary")),
        WordCell(word: "local government", isKnown: .unKnown, trans: define("local government")),
    ])
    
    static var previews: some View {
        Group {
            // colorways apple-dict colourway
//            LandscapeWordsView()
//                .environmentObject(sampleWords(["the left", "scepter", "colorway", "Latin"]))
//                .frame(width: 1000, height: 150)
//
//            LandscapeWordsView()
//                .environmentObject(sampleWords(["scepter"]))
//                .frame(width: 1000, height: 150)
            
//            // use max width 170, landscape normal test the displaying difference of "local government"
//            LandscapeWordsView()
//                .environmentObject(displayedWords2)
//                .frame(width: 1000, height: 150)
//
//            LandscapeWordsView()
//                .environmentObject(displayedWords3)
//                .frame(width: 1000, height: 150)
//
            PortraitWordsView()
                .environmentObject(displayedWords2)
                .frame(width: 300, height: 600)
//
//            PortraitWordsView()
//                .environmentObject(displayedWords3)
//                .frame(width: 300, height: 600)
        }
    }
}

