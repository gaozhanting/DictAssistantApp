//
//  SettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/20.
//

import SwiftUI
import Preferences

extension Preferences.PaneIdentifier {
    static let general = Self("general")
    static let appearance = Self("appearance")
    static let dictionaries = Self("dictionaries")
}

let GeneralPreferenceViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!
    ) {
        GeneralSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

let AppearancePreferenceViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .appearance,
        title: "Appearance",
        toolbarIcon: NSImage(systemSymbolName: "eyeglasses", accessibilityDescription: "Appearance preferences")!
    ) {
        AppearanceSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

let DictionariesPreferenceViewController: () -> PreferencePane = {
    let paneView = Preferences.Pane(
        identifier: .dictionaries,
        title: "Dictionaries",
        toolbarIcon: NSImage(systemSymbolName: "books.vertical", accessibilityDescription: "Dictionaries preferences")!
    ) {
        DictionariesView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}
