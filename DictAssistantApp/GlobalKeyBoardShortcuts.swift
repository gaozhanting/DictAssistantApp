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
}
