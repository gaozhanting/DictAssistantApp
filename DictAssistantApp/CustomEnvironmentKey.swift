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

private struct CropperUpEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var cropperUp: () -> Void {
        get { self[CropperUpEnvironmentKey].self }
        set { self[CropperUpEnvironmentKey.self] = newValue }
    }
}

private struct CropperDownEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var cropperDown: () -> Void {
        get { self[CropperDownEnvironmentKey].self }
        set { self[CropperDownEnvironmentKey.self] = newValue }
    }
}

private struct ToggleContentPanelOpaqueEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var toggleContentPanelOpaque: () -> Void {
        get { self[ToggleContentPanelOpaqueEnvironmentKey].self }
        set { self[ToggleContentPanelOpaqueEnvironmentKey.self] = newValue }
    }
}

private struct RestartScreenCaptureWithNewTimeIntervalEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var restartScreenCaptureWithNewTimeInterval: () -> Void {
        get { self[RestartScreenCaptureWithNewTimeIntervalEnvironmentKey].self }
        set { self[RestartScreenCaptureWithNewTimeIntervalEnvironmentKey.self] = newValue }
    }
}

private struct ToggleScreenCaptureEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var toggleScreenCapture: () -> Void {
        get { self[ToggleScreenCaptureEnvironmentKey].self }
        set { self[ToggleScreenCaptureEnvironmentKey.self] = newValue }
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

private struct SyncContentPanelFromDisplayModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var syncContentPanelFromDisplayMode: () -> Void {
        get { self[SyncContentPanelFromDisplayModeEnvironmentKey].self }
        set { self[SyncContentPanelFromDisplayModeEnvironmentKey.self] = newValue }
    }
}
