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
    static let recording = Self("recording")
    static let vision = Self("vision")
    static let english = Self("english")
    static let content = Self("content")
    static let appearance = Self("appearance")
    static let slots = Self("slots")
    static let dictionaries = Self("dictionaries")
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

func RecordingPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .recording,
        title: NSLocalizedString("Recording", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "rectangle.dashed.badge.record", accessibilityDescription: "Recording preferences")!
    ) {
        RecordingSettingsView()
            .environmentObject(statusData)
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func VisionPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .vision,
        title: NSLocalizedString("Vision", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "doc.text.viewfinder", accessibilityDescription: "Vision preferences")!
    ) {
        VisionSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func EnglishPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .english,
        title: NSLocalizedString("English", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "textformat.abc", accessibilityDescription: "English preferences")!
    ) {
        EnglishSettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func ContentPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .content,
        title: NSLocalizedString("Content", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "scroll", accessibilityDescription: "Content preferences")!
    ) {
        ContentSettingsView()
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
        toolbarIcon: NSImage(systemSymbolName: "cube.fill", accessibilityDescription: "Slots preferences")!
    ) {
        SlotsSettingsView()
            .environmentObject(statusData)
            .environment(\.managedObjectContext, managedObjectContext)
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
