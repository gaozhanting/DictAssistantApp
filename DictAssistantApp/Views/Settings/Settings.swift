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
    static let slots = Self("slots") // -- above are universal options, slot, below are scenario options
    static let recording = Self("recording")
    static let vision = Self("vision")
    static let cropper = Self("cropper")
    static let content = Self("content")
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
        toolbarIcon: NSImage(systemSymbolName: "cube.fill", accessibilityDescription: "Slots preferences")!
    ) {
        SlotsSettingsView()
            .environmentObject(statusData)
            .environment(\.managedObjectContext, managedObjectContext)
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

func CropperPreferenceViewController() -> PreferencePane {
    let paneView = Preferences.Pane(
        identifier: .cropper,
        title: NSLocalizedString("Cropper", comment: ""),
        toolbarIcon: NSImage(systemSymbolName: "crop", accessibilityDescription: "Cropper preferences")!
    ) {
        CropperSettingsView()
    }
    
    return Preferences.PaneHostingController(pane: paneView)
}
