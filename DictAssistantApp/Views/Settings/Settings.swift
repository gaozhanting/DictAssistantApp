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
    static let slots = Self("slots")
    static let dictionaries = Self("dictionaries")
}

func GeneralPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .general,
        title: "General",
        toolbarIcon: NSImage(systemSymbolName: "gear", accessibilityDescription: "General preferences")!
    ) {
        GeneralSettingsView()
            .environmentObject(statusData)
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func AppearancePreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .appearance,
        title: "Appearance",
        toolbarIcon: NSImage(systemSymbolName: "eyeglasses", accessibilityDescription: "Appearance preferences")!
    ) {
        AppearanceSettingsView()
            .environmentObject(statusData)
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func SlotsPreferenceViewController(managedObjectContext: NSManagedObjectContext) -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .slots,
        title: "Slots",
        toolbarIcon: NSImage(systemSymbolName: "cube.fill", accessibilityDescription: "Slots preferences")!
    ) {
        SlotsSettingsView()
            .environmentObject(statusData)
            .environment(\.managedObjectContext, managedObjectContext)
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
