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
private struct BatchUpsertCustomDictsEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([Entry]) -> Void = { _ in }
}

extension EnvironmentValues {
    var batchUpsertCustomDicts: ([Entry]) -> Void {
        get { self[BatchUpsertCustomDictsEnvironmentKey].self }
        set { self[BatchUpsertCustomDictsEnvironmentKey.self] = newValue }
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

// Custom Phrases (core data operations)
private struct BatchInsertCustomPhrasesEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([String]) -> Void = { _ in }
}

extension EnvironmentValues {
    var batchInsertCustomPhrases: ([String]) -> Void {
        get { self[BatchInsertCustomPhrasesEnvironmentKey].self }
        set { self[BatchInsertCustomPhrasesEnvironmentKey.self] = newValue }
    }
}

private struct removeMultiCustomPhrasesEnvironmentKey: EnvironmentKey {
    static let defaultValue: ([String]) -> Void = { _ in }
}

extension EnvironmentValues {
    var removeMultiCustomPhrases: ([String]) -> Void {
        get { self[removeMultiCustomPhrasesEnvironmentKey].self }
        set { self[removeMultiCustomPhrasesEnvironmentKey.self] = newValue }
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
