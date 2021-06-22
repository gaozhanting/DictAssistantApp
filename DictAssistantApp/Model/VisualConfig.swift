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

//enum CropperStyle {
//    case closed
//    case mini
//    case normal
//}

class VisualConfig: ObservableObject {
    @Published private var miniModeInner: Bool
    @Published var displayMode: DisplayMode
    @Published var fontSizeOfLandscape: CGFloat
    @Published var fontSizeOfPortrait: CGFloat
    @Published var colorOfLandscape: NSColor
    @Published var colorOfPortrait: NSColor
    @Published var fontName: String
    @Published var showStrokeBorder: Bool // Cropper Style
//    @Published var cropperStyleInner: CropperStyle
    
    var miniMode: Bool {
        get {
            miniModeInner
        }
        set {
            miniModeInner = newValue
            setSideEffectCode()
        }
    }
    
    var setSideEffectCode: () -> Void

    init(
        miniModeInner: Bool,
        displayMode: DisplayMode,
        fontSizeOfLandscape: CGFloat,
        fontSizeOfPortrait: CGFloat,
        colorOfLandscape: NSColor,
        colorOfPortrait: NSColor,
        fontName: String,
        showStrokeBorder: Bool,
        setSideEffectCode: @escaping () -> Void
    ) {
        self.miniModeInner = miniModeInner
        self.displayMode = displayMode
        self.fontSizeOfLandscape = fontSizeOfLandscape
        self.fontSizeOfPortrait = fontSizeOfPortrait
        self.colorOfLandscape = colorOfLandscape
        self.colorOfPortrait = colorOfPortrait
        self.fontName = fontName
        self.showStrokeBorder = showStrokeBorder
        self.setSideEffectCode = setSideEffectCode
    }
}
