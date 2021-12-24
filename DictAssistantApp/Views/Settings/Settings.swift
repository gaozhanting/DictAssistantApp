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
    static let language = Self("language")
    static let appearance = Self("appearance")
    static let slots = Self("slots")
    static let scenario = Self("scenario")
}

func GeneralPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .general,
        title: NSLocalizedString("General", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "gearshape", accessibilityDescription: "General preferences")!
    ) {
        GeneralSettingsView()
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

func SlotsPreferenceViewController(managedObjectContext: NSManagedObjectContext) -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .slots,
        title: NSLocalizedString("Slots", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "shippingbox.circle", accessibilityDescription: "Slots preferences")!
    ) {
        SlotsSettingsView()
            .environmentObject(statusData)
            .environment(\.managedObjectContext, managedObjectContext)
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}

func ScenarioPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .scenario,
        title: NSLocalizedString("Scenario", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "shippingbox", accessibilityDescription: "Scenario preferences")!
    ) {
        ScenarioSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
