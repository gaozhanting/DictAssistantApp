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

private struct ResetUserDefaultsEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var resetUserDefaults: () -> Void {
        get { self[ResetUserDefaultsEnvironmentKey].self }
        set { self[ResetUserDefaultsEnvironmentKey.self] = newValue }
    }
}

private struct ShowFontsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (Any?) -> Void = {_ in }
}

extension EnvironmentValues {
    var showFonts: (Any?) -> Void {
        get { self[ShowFontsEnvironmentKey].self }
        set { self[ShowFontsEnvironmentKey.self] = newValue }
    }
}

private struct ChangeFontEnvironmentKey: EnvironmentKey {
    static let defaultValue: (NSFontManager?) -> Void = {_ in }
}

extension EnvironmentValues {
    var changeFont: (NSFontManager?) -> Void {
        get { self[ChangeFontEnvironmentKey].self }
        set { self[ChangeFontEnvironmentKey.self] = newValue }
    }
}

private struct SyncContentPanelFromVisualConfigEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var syncContentPanelFromVisualConfig: () -> Void {
        get { self[SyncContentPanelFromVisualConfigEnvironmentKey].self }
        set { self[SyncContentPanelFromVisualConfigEnvironmentKey.self] = newValue }
    }
}

private struct ShowColorPanelEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var showColorPanel: () -> Void {
        get { self[ShowColorPanelEnvironmentKey].self }
        set { self[ShowColorPanelEnvironmentKey.self] = newValue }
    }
}
