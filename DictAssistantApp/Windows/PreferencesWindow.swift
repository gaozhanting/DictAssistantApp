//
//  PreferencesWindow.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Foundation
import Preferences

var preferencesWindowController = PreferencesWindowController(
    preferencePanes: [
        ScenarioPreferenceViewController(),
        LanguagePreferenceViewController(),
        AppearancePreferenceViewController(),
        ShortcutsPreferenceViewController(),
        SlotsPreferenceViewController(managedObjectContext: persistentContainer.viewContext)
    ],
    style: .toolbarItems,
    animated: false,
    hidesToolbarForSingleItem: true
)

extension AppDelegate {
    @objc func showPreferences() {
        preferencesWindowController.show()
    }
}

func showSlotsTab() {
    preferencesWindowController.show(preferencePane: .slots)
}
