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
        AppearancePreferenceViewController(),
        SlotsPreferenceViewController(managedObjectContext: persistentContainer.viewContext),
        RecordingPreferenceViewController(),
        VisionPreferenceViewController(),
        ContentPreferenceViewController(),
    ],
    style: .toolbarItems,
    animated: true,
    hidesToolbarForSingleItem: true
)

extension AppDelegate {
    @objc func showPreferences() {
        showPreferencesPanel()
    }
}

func showPreferencesPanel() {
    preferencesWindowController.show()
}

func fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() {
    preferencesWindowController.show(preferencePane: .content)
    preferencesWindowController.show(preferencePane: .vision)
    preferencesWindowController.show(preferencePane: .recording)
    preferencesWindowController.show(preferencePane: .slots)
    preferencesWindowController.show(preferencePane: .appearance)
    preferencesWindowController.show(preferencePane: .dictionary)
    preferencesWindowController.show(preferencePane: .nlp)
    preferencesWindowController.show(preferencePane: .general)
    preferencesWindowController.close()
}
