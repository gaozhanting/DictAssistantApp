//
//  CustomEnvironmentKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/6.
//

import SwiftUI

private struct ToggleCropperEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var toggleCropper: () -> Void {
        get { self[ToggleCropperEnvironmentKey.self] }
        set { self[ToggleCropperEnvironmentKey.self] = newValue }
    }
}

private struct ToggleContentEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var toggleContent: () -> Void {
        get { self[ToggleContentEnvironmentKey].self }
        set { self[ToggleContentEnvironmentKey.self] = newValue }
    }
}

private struct DeleteAllWordStaticsticsEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var deleteAllWordStaticstics: () -> Void {
        get { self[DeleteAllWordStaticsticsEnvironmentKey].self }
        set { self[DeleteAllWordStaticsticsEnvironmentKey.self] = newValue }
    }
}
