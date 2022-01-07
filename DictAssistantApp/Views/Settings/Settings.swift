//
//  SettingsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/20.
//

import SwiftUI
import Preferences

extension Preferences.PaneIdentifier {
    static let scenario = Self("scenario")
    static let language = Self("language")
    static let appearance = Self("appearance")
    static let shortcuts = Self("shortcuts")
    static let slots = Self("slots")
}

func ScenarioPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .scenario,
        title: NSLocalizedString("Scenario", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "gear", accessibilityDescription: "Scenario preferences")!
    ) {
        ScenarioSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}

func LanguagePreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .language,
        title: NSLocalizedString("Language", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "building.columns", accessibilityDescription: "Language preferences")!
    ) {
        LanguageSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func AppearancePreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .appearance,
        title: NSLocalizedString("Appearance", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "eyeglasses", accessibilityDescription: "Appearance preferences")!
    ) {
        AppearanceSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func ShortcutsPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .shortcuts,
        title: NSLocalizedString("Shortcuts", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Shortcuts preferences")!
    ) {
        ShortcutsSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func SlotsPreferenceViewController(managedObjectContext: NSManagedObjectContext) -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .slots,
        title: NSLocalizedString("Slots", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "cube", accessibilityDescription: "Slots preferences")!
    ) {
        SlotsSettingsView()
            .environmentObject(statusData)
            .environment(\.managedObjectContext, managedObjectContext)
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
