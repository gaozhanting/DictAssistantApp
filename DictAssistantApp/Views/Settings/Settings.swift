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
    static let nlp = Self("nlp")
    static let dictionary = Self("dictionary")
    static let transcript = Self("transcript")
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

func NLPPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .nlp,
        title: NSLocalizedString("NLP", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "n.square", accessibilityDescription: "NLP preferences")!
    ) {
        NLPSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}

func DictionaryPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .dictionary,
        title: NSLocalizedString("Dictionary", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "building.columns", accessibilityDescription: "Dictionary preferences")!
    ) {
        DictionarySettingsView()
    }

    return Preferences.PaneHostingController(pane: paneView)
}

func TranscriptePreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .transcript,
        title: NSLocalizedString("Transcript", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "rectangle.and.pencil.and.ellipsis", accessibilityDescription: "Transcript preferences")!
    ) {
        TranscriptSettingsView()
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
        toolbarIcon: NSImage(systemSymbolName: "shippingbox", accessibilityDescription: "Slots preferences")!
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
        toolbarIcon: NSImage(systemSymbolName: "shippingbox.circle", accessibilityDescription: "Scenario preferences")!
    ) {
        ScenarioSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
