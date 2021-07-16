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

private struct SetFontRateEnvironmentKey: EnvironmentKey {
    static let defaultValue: (CGFloat) -> Void = { _ in }
}

extension EnvironmentValues {
    var setFontRate: (CGFloat) -> Void {
        get { self[SetFontRateEnvironmentKey].self }
        set { self[SetFontRateEnvironmentKey.self] = newValue }
    }
}

private struct SetAddlineBreakEnvironmentKey: EnvironmentKey {
    static let defaultValue: (Bool) -> Void = { _ in }
}

extension EnvironmentValues {
    var setAddlineBreak: (Bool) -> Void {
        get { self[SetAddlineBreakEnvironmentKey].self }
        set { self[SetAddlineBreakEnvironmentKey.self] = newValue }
    }
}

private struct SetIsDisplayKnownWordsEnvironmentKey: EnvironmentKey {
    static let defaultValue: (Bool) -> Void = { _ in }
}

extension EnvironmentValues {
    var setIsDisplayKnownWords: (Bool) -> Void {
        get { self[SetIsDisplayKnownWordsEnvironmentKey].self }
        set { self[SetIsDisplayKnownWordsEnvironmentKey.self] = newValue }
    }
}
