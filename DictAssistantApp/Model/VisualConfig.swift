//
//  VisualConfig.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/8.
//

import Foundation
import AppKit.NSColor

class VisualConfig: ObservableObject {
    @Published var fontSizeOfLandscape: CGFloat
    @Published var fontSizeOfPortrait: CGFloat
    @Published var colorOfLandscape: NSColor
    @Published var colorOfPortrait: NSColor
    @Published var fontName: String

    init(
        fontSizeOfLandscape: CGFloat,
        fontSizeOfPortrait: CGFloat,
        colorOfLandscape: NSColor,
        colorOfPortrait: NSColor,
        fontName: String
    ) {
        self.fontSizeOfLandscape = fontSizeOfLandscape
        self.fontSizeOfPortrait = fontSizeOfPortrait
        self.colorOfLandscape = colorOfLandscape
        self.colorOfPortrait = colorOfPortrait
        self.fontName = fontName
    }
}
