//
//  CustomEnvironmentKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/6.
//

import SwiftUI

private struct CloseContentPanelEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var closeContentPanel: () -> Void {
        get { self[CloseContentPanelEnvironmentKey].self }
        set { self[CloseContentPanelEnvironmentKey.self] = newValue }
    }
}

private struct ShowContentPanelEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var showContentPanel: () -> Void {
        get { self[ShowContentPanelEnvironmentKey].self }
        set { self[ShowContentPanelEnvironmentKey.self] = newValue }
    }
}

private struct AddToKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

extension EnvironmentValues {
    var addToKnownWords: (String) -> Void {
        get { self[AddToKnownWordsEnvironmentKey].self }
        set { self[AddToKnownWordsEnvironmentKey.self] = newValue }
    }
}
