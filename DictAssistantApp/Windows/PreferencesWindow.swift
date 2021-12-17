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
        RecordingPreferenceViewController(),
        VisionPreferenceViewController(),
        CropperPreferenceViewController(),
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
    preferencesWindowController.show(preferencePane: .cropper)
    preferencesWindowController.show(preferencePane: .vision)
    preferencesWindowController.show(preferencePane: .recording)
    preferencesWindowController.show(preferencePane: .slots)
    preferencesWindowController.show(preferencePane: .appearance)
    preferencesWindowController.show(preferencePane: .transcript)
    preferencesWindowController.show(preferencePane: .dictionary)
    preferencesWindowController.show(preferencePane: .nlp)
    preferencesWindowController.show(preferencePane: .general)
    preferencesWindowController.close()
}
