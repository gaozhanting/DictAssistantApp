//
//  VisualConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/8.
//

import Foundation

enum DisplayMode: String, CaseIterable, Identifiable {
    case landscape // for reading subtitle when watching movie
    case portrait // for reading articles
    
    var id: String { self.rawValue }
}

class VisualConfig: ObservableObject {
    @Published var displayMode: DisplayMode
    @Published var fontSizeOfLandscape: CGFloat
    @Published var fontSizeOfPortrait: CGFloat
    
    init(displayMode: DisplayMode, fontSizeOfLandscape: CGFloat, fontSizeOfPortrait: CGFloat) {
        self.displayMode = displayMode
        self.fontSizeOfLandscape = fontSizeOfLandscape
        self.fontSizeOfPortrait = fontSizeOfPortrait
    }
}
