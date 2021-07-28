//
//  GlobalShortCutKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleUnicornMode = Self("toggleUnicornMode", default: .init(.e, modifiers: [.command, .control]))
    
    static let toggleShowCurrentKnownWords = Self("toggleShowCurrentKnownWords", default: .init(.r, modifiers: [.command, .control]))
    
    static let reloadContentView = Self("reloadContentView", default: .init(.t, modifiers: [.command, .control]))
}
