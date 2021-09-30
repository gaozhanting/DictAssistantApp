//
//  CustomEnvironmentKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/6.
//

import SwiftUI

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
