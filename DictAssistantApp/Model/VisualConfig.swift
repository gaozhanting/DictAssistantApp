//
//  VisualConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/8.
//

import Foundation
import AppKit.NSColor

enum DisplayMode: String, CaseIterable, Identifiable {
    case landscape // for reading subtitle when watching movie
    case portrait // for reading articles
    
    var id: String { self.rawValue }
}

class VisualConfig: ObservableObject {
    @Published var miniMode: Bool
    @Published var displayMode: DisplayMode
    @Published var fontSizeOfLandscape: CGFloat
    @Published var fontSizeOfPortrait: CGFloat
    @Published var colorOfLandscape: NSColor
    @Published var colorOfPortrait: NSColor
    @Published var fontName: String
    
    init(
        miniMode: Bool,
        displayMode: DisplayMode,
        fontSizeOfLandscape: CGFloat,
        fontSizeOfPortrait: CGFloat,
        colorOfLandscape: NSColor,
        colorOfPortrait: NSColor,
        fontName: String
    ) {
        self.miniMode = miniMode
        self.displayMode = displayMode
        self.fontSizeOfLandscape = fontSizeOfLandscape
        self.fontSizeOfPortrait = fontSizeOfPortrait
        self.colorOfLandscape = colorOfLandscape
        self.colorOfPortrait = colorOfPortrait
        self.fontName = fontName
    }
}
