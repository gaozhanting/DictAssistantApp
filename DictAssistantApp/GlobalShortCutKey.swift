//
//  GlobalShortCutKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let runStepPlay = Self("runStepPlay")
    
    static let switchAnchor = Self("switchAnchor")
    
    static let toggleAddLineBreak = Self("toggleAddLineBreak")
    
    static let toggleShowKnown = Self("toggleShowKnown")
    
    static let toggleShowNotFound = Self("toggleShowNotFound")
    
    static let toggleShowKnownButWithOpacity0 = Self("toggleShowKnownButWithOpacity0")
    
    static let toggleConcealTranslation = Self("toggleConcealTranslation")
    
    static let runQuickPlay = Self("runQuickPlay")
    
    static let runCheapSnapshot = Self("runCheapSnapshot")
    
    static let stop = Self("stop")
    
    static let toggleMiniKnownPanel = Self("toggleMiniKnownPanel")
    
    static let toggleMiniPhrasePanel = Self("toggleMiniPhrasePanel")
    
    static let toggleMiniEntryPanel = Self("toggleMiniEntryPanel")
    
    static let showSlotsTab = Self("showSlotsTab")
}

enum StepPlayPhase {
    case defaultPhase
    case windowsSettingPhase
}

var stepPlayPhase: StepPlayPhase = .defaultPhase

func makeWindowsForSetting() {
    cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperAnimationView())
    cropperWindow.orderFrontRegardless()

    let emptyView = EmptyView()
        .background(VisualEffectView(material: .hudWindow))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    contentWindow.contentView = NSHostingView(rootView: emptyView)
    contentWindow.orderFrontRegardless()
}

func registerGlobalKey() {
    KeyboardShortcuts.onKeyUp(for: .runStepPlay) {
        if !statusData.isPlaying {
            switch stepPlayPhase {
            case .defaultPhase:
                makeWindowsForSetting()
                stepPlayPhase = .windowsSettingPhase
                
            case .windowsSettingPhase:
                startPlaying()
            }
        }
        else {
            stopPlaying()
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .switchAnchor) {
        switch calculateLayout(from: contentWindow.frame) {
        case .portrait:
            switch PortraitCorner(rawValue: UserDefaults.standard.PortraitCornerKey)! {
            case .top:
                UserDefaults.standard.PortraitCornerKey = PortraitCorner.topTrailing.rawValue
            case .topTrailing:
                UserDefaults.standard.PortraitCornerKey = PortraitCorner.topLeading.rawValue
            case .topLeading:
                UserDefaults.standard.PortraitCornerKey = PortraitCorner.bottom.rawValue
            case .bottom:
                UserDefaults.standard.PortraitCornerKey = PortraitCorner.top.rawValue
            }
        case .landscape:
            switch LandscapeStyle(rawValue: UserDefaults.standard.LandscapeStyleKey)! {
            case .normal:
                UserDefaults.standard.LandscapeStyleKey = LandscapeStyle.centered.rawValue
            case .centered:
                UserDefaults.standard.LandscapeStyleKey = LandscapeStyle.normal.rawValue
            }
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleAddLineBreak) {
        if UserDefaults.standard.bool(forKey: IsAddLineBreakKey) {
            UserDefaults.standard.setValue(false, forKey: IsAddLineBreakKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsAddLineBreakKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowKnown) {
        if UserDefaults.standard.bool(forKey: IsShowKnownKey) {
            UserDefaults.standard.setValue(false, forKey: IsShowKnownKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowKnownKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowKnownButWithOpacity0) {
        if UserDefaults.standard.bool(forKey: IsShowKnownButWithOpacity0Key) {
            UserDefaults.standard.setValue(false, forKey: IsShowKnownButWithOpacity0Key)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowKnownButWithOpacity0Key)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleConcealTranslation) {
        if UserDefaults.standard.bool(forKey: IsConcealTranslationKey) {
            UserDefaults.standard.setValue(false, forKey: IsConcealTranslationKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsConcealTranslationKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowNotFound) {
        if UserDefaults.standard.bool(forKey: IsShowNotFoundKey) {
            UserDefaults.standard.setValue(false, forKey: IsShowNotFoundKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowNotFoundKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .runQuickPlay) {
        if !statusData.isPlaying {
            startPlaying()
        } else {
            stopPlaying()
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .runCheapSnapshot) {
        snapshotState = 1 // issue when something goes wrong, how to reset this value
        startPlaying()
    }
    
    KeyboardShortcuts.onKeyUp(for: .stop) {
        snapshotState = 0 // above issue resolved here
        stopPlaying()
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleMiniKnownPanel) {
        toggleMiniKnownPanel()
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleMiniPhrasePanel) {
        toggleMiniPhrasePanel()
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleMiniEntryPanel) {
        toggleMiniEntryPanel()
    }
    
    KeyboardShortcuts.onKeyUp(for: .showSlotsTab) {
        showSlotsTab()
    }
}

var snapshotState: Int = 0

private func startPlaying() {
    stepPlayPhase = .defaultPhase

    let cropperStyle = CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!
    syncCropperView(from: cropperStyle)
    fixCropperWindow()
    
    let contentView = ContentView()
        .environment(\.managedObjectContext, persistentContainer.viewContext)
        .environmentObject(displayedWords)
        .environmentObject(contentWindowLayout)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    contentWindow.contentView = NSHostingView(rootView: contentView)
    contentWindow.orderFrontRegardless()
    
    toastOn()
    statusData.isPlaying = true
    statusItem.button?.image = NSImage(named: "FullIcon")

    displayedWords.wordCells = []
    hlBox.indexedBoxes = []
    trTextsCache = []
    primitiveWordCellCache = []
    
    aVSessionAndTR.startScreenCapture()
}

private func stopPlaying() {
    stepPlayPhase = .defaultPhase

    activeCropperWindow()
    cropperWindow.close()
    contentWindow.close()
    
    toastOff()
    statusData.isPlaying = false
    statusItem.button?.image = NSImage(named: "EmptyIcon")

    displayedWords.wordCells = []
    hlBox.indexedBoxes = []
    trTextsCache = []
    primitiveWordCellCache = []
    
    aVSessionAndTR.stopScreenCapture()
}

func restartPlaying() {
    stopPlaying()
    startPlaying()
}

// no resizable, not movable
private func fixCropperWindow() {
    // remove .resizable otherwise can't mouse through
    cropperWindow.styleMask = [
        .fullSizeContentView
    ]
    cropperWindow.isMovable = false
    cropperWindow.isMovableByWindowBackground = false
}

// resizable, movable
func activeCropperWindow() {
    cropperWindow.styleMask = [
        .fullSizeContentView,
        .resizable,
    ]
    cropperWindow.isMovable = true
    cropperWindow.isMovableByWindowBackground = true
    
    // otherwise three dots appear and zoom button enabled
    cropperWindow.standardWindowButton(.closeButton)?.isHidden = true
    cropperWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
    cropperWindow.standardWindowButton(.zoomButton)?.isHidden = true
    cropperWindow.standardWindowButton(.toolbarButton)?.isHidden = true
}
