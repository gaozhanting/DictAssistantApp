//
//  GlobalKeyBoardShortcuts.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/5/20.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let startOrPause = Self(
        "startOrPause",
        default: .init(.s, modifiers: [.command, .control]))
    static let exit = Self(
        "exit",
        default: .init(.x, modifiers: [.command, .control]))
    static let toggleContentPanelOpaque = Self(
        "toggleContentPanelOpaque",
        default: .init(.o, modifiers: [.command, .control]))
    static let toggleCropperWindowOpaque = Self(
        "toggleCropperWindowOpaque",
        default: .init(.c, modifiers: [.command, .control]))
    static let cropperUp = Self(
        "cropperUp",
        default: .init(.upArrow, modifiers: [.command, .control]))
    static let cropperDown = Self(
        "cropperDown",
        default: .init(.downArrow, modifiers: [.command, .control]))
    static let resetUserDefaults = Self(
        "resetUserDefaults",
        default: .init(.r, modifiers: [.command, .control]))
}

// https://support.apple.com/en-us/HT201236
// Control-Command- T A D F Q
