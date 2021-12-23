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
        GeneralPreferenceViewController(),
        NLPPreferenceViewController(),
        DictionaryPreferenceViewController(),
        TranscriptePreferenceViewController(),
        AppearancePreferenceViewController(),
        SlotsPreferenceViewController(managedObjectContext: persistentContainer.viewContext),
        ScenarioPreferenceViewController()
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

func fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() {
    preferencesWindowController.show(preferencePane: .scenario)
    preferencesWindowController.show(preferencePane: .slots)
    preferencesWindowController.show(preferencePane: .appearance)
    preferencesWindowController.show(preferencePane: .transcript)
    preferencesWindowController.show(preferencePane: .dictionary)
    preferencesWindowController.show(preferencePane: .nlp)
    preferencesWindowController.show(preferencePane: .general)
    preferencesWindowController.close()
}
