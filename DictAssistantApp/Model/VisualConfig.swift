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

enum CropperStyle: String, CaseIterable, Identifiable {
    case closed
    case mini
    case rectangle
    
    var id: String { self.rawValue }
}

class VisualConfig: ObservableObject {
    @Published private var miniModeInner: Bool
    @Published var displayModeInner: DisplayMode
    @Published var fontSizeOfLandscape: CGFloat
    @Published var fontSizeOfPortrait: CGFloat
    @Published var colorOfLandscape: NSColor
    @Published var colorOfPortrait: NSColor
    @Published var fontName: String
    @Published var cropperStyleInner: CropperStyle
    
    var miniMode: Bool {
        get {
            miniModeInner
        }
        set {
            miniModeInner = newValue
            setSideEffectCode()
        }
    }
    
    var cropperStyle: CropperStyle {
        get {
            cropperStyleInner
        }
        set {
            cropperStyleInner = newValue
            setSideEffectCode()
        }
    }
    
    var displayMode: DisplayMode {
        get {
            displayModeInner
        }
        set {
            displayModeInner = newValue
            setSideEffectCode()
            switchWordsPanel()
        }
    }
    
    var setSideEffectCode: () -> Void
    var switchWordsPanel: () -> Void

    init(
        miniModeInner: Bool,
        displayModeInner: DisplayMode,
        fontSizeOfLandscape: CGFloat,
        fontSizeOfPortrait: CGFloat,
        colorOfLandscape: NSColor,
        colorOfPortrait: NSColor,
        fontName: String,
        cropperStyleInner: CropperStyle,
        setSideEffectCode: @escaping () -> Void,
        switchWordsPanel: @escaping () -> Void
    ) {
        self.miniModeInner = miniModeInner
        self.displayModeInner = displayModeInner
        self.fontSizeOfLandscape = fontSizeOfLandscape
        self.fontSizeOfPortrait = fontSizeOfPortrait
        self.colorOfLandscape = colorOfLandscape
        self.colorOfPortrait = colorOfPortrait
        self.fontName = fontName
        self.cropperStyleInner = cropperStyleInner
        self.setSideEffectCode = setSideEffectCode
        self.switchWordsPanel = switchWordsPanel
    }
}
