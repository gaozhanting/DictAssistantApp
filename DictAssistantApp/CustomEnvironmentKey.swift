//
//  CustomEnvironmentKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/6.
//

import SwiftUI

private struct AddToKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

extension EnvironmentValues {
    var addToKnownWords: (String) -> Void {
        get { self[AddToKnownWordsEnvironmentKey].self }
        set { self[AddToKnownWordsEnvironmentKey.self] = newValue }
    }
}

private struct RemoveFromKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

extension EnvironmentValues {
    var removeFromKnownWords: (String) -> Void {
        get { self[RemoveFromKnownWordsEnvironmentKey].self }
        set { self[RemoveFromKnownWordsEnvironmentKey.self] = newValue }
    }
}
