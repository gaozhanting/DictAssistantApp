//
//  PreferencesWindow.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Foundation
import Preferences

private var preferencesWindowController = PreferencesWindowController(
    preferencePanes: [
        GeneralPreferenceViewController(),
        VisionPreferenceViewController(),
        ContentPreferenceViewController(),
        AppearancePreferenceViewController(),
        SlotsPreferenceViewController(managedObjectContext: persistentContainer.viewContext),
    ],
    style: .toolbarItems,
    animated: true,
    hidesToolbarForSingleItem: true
)

extension AppDelegate {
    @objc func showPreferences() {
        preferencesWindowController.show()
    }
}

func fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() {
    preferencesWindowController.show(preferencePane: .slots)
    preferencesWindowController.show(preferencePane: .appearance)
    preferencesWindowController.show(preferencePane: .content)
    preferencesWindowController.show(preferencePane: .vision)
    preferencesWindowController.show(preferencePane: .general)
    preferencesWindowController.close()
}
