//
//  GlobalShortCutKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleUnicornMode = Self("toggleUnicornMode", default: .init(.e, modifiers: [.command, .control]))
    
    static let cancelUnicornMode = Self("cancelUnicornMode", default: .init(.r, modifiers: [.command, .control]))
}