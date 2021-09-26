//
//  CustomEnvironmentKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/6.
//

import SwiftUI

// Known Words List (core data operations)
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

private struct AddMultiToKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([String]) -> Void = { _ in }
}

extension EnvironmentValues {
    var addMultiToKnownWords: ([String]) -> Void {
        get { self[AddMultiToKnownWordsEnvironmentKey].self }
        set { self[AddMultiToKnownWordsEnvironmentKey.self] = newValue }
    }
}

private struct RemoveMultiFromKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([String]) -> Void = { _ in }
}

extension EnvironmentValues {
    var removeMultiFromKnownWords: ([String]) -> Void {
        get { self[RemoveMultiFromKnownWordsEnvironmentKey].self }
        set { self[RemoveMultiFromKnownWordsEnvironmentKey.self] = newValue }
    }
}

// Custom Dict (core data operations)
private struct AddMultiEntriesToCustomDictEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([Entry]) -> Void = { _ in }
}

extension EnvironmentValues {
    var addMultiEntriesToCustomDict: ([Entry]) -> Void {
        get { self[AddMultiEntriesToCustomDictEnvironmentKey].self }
        set { self[AddMultiEntriesToCustomDictEnvironmentKey.self] = newValue }
    }
}

private struct RemoveMultiWordsFromCustomDictEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([String]) -> Void = { _ in }
}

extension EnvironmentValues {
    var removeMultiWordsFromCustomDict: ([String]) -> Void {
        get { self[RemoveMultiWordsFromCustomDictEnvironmentKey].self }
        set { self[RemoveMultiWordsFromCustomDictEnvironmentKey.self] = newValue }
    }
}

private struct RefreshContentWhenChangingUseCustomDictModeEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var refreshContentWhenChangingUseCustomDictMode: () -> Void {
        get { self[RefreshContentWhenChangingUseCustomDictModeEnvironmentKey].self }
        set { self[RefreshContentWhenChangingUseCustomDictModeEnvironmentKey.self] = newValue }
    }
}

// Onboarding close panel
private struct EndOnboardingEnvironmentKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var endOnboarding: () -> Void {
        get { self[EndOnboardingEnvironmentKey].self }
        set { self[EndOnboardingEnvironmentKey.self] = newValue }
    }
}
