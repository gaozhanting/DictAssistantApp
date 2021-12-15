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
    
    static let toggleShowCurrentKnown = Self("toggleShowCurrentKnown")
    
    static let toggleShowCurrentNotFoundWords = Self("toggleShowCurrentNotFoundWords")
    
    static let toggleShowCurrentKnownButWithOpacity0 = Self("toggleShowCurrentKnownButWithOpacity0")
    
    static let toggleConcealTranslation = Self("toggleConcealTranslation")
    
    static let runQuickPlay = Self("runQuickPlay")
    
    static let runCheapSnapshot = Self("runCheapSnapshot")
    
    static let stop = Self("stop")
    
    static let showPhraseInsertPanel = Self("showPhraseInsertPanel")
    
    static let showUpsertEntryPanel = Self("showUpsertEntryPanel")
    
    static let showPreferencesPanel = Self("showPreferencesPanel")
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
                
                stepPlayPhase = .defaultPhase
            }
        }
        else {
            stopPlaying()
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowCurrentKnown) {
        if UserDefaults.standard.bool(forKey: IsShowCurrentKnownKey) {
            UserDefaults.standard.setValue(false, forKey: IsShowCurrentKnownKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowCurrentKnownKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowCurrentKnownButWithOpacity0) {
        if UserDefaults.standard.bool(forKey: IsShowCurrentKnownButWithOpacity0Key) {
            UserDefaults.standard.setValue(false, forKey: IsShowCurrentKnownButWithOpacity0Key)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowCurrentKnownButWithOpacity0Key)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleConcealTranslation) {
        if UserDefaults.standard.bool(forKey: IsConcealTranslationKey) {
            UserDefaults.standard.setValue(false, forKey: IsConcealTranslationKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsConcealTranslationKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowCurrentNotFoundWords) {
        if UserDefaults.standard.bool(forKey: IsShowCurrentNotFoundWordsKey) {
            UserDefaults.standard.setValue(false, forKey: IsShowCurrentNotFoundWordsKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowCurrentNotFoundWordsKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .runQuickPlay) {
        if !statusData.isPlaying {
            startPlaying()
            
            stepPlayPhase = .defaultPhase
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
    
    KeyboardShortcuts.onKeyUp(for: .showPhraseInsertPanel) {
        showPhraseInsertPanel()
    }
    
    KeyboardShortcuts.onKeyUp(for: .showUpsertEntryPanel) {
        showEntryUpsertPanel()
    }
    
    KeyboardShortcuts.onKeyUp(for: .showPreferencesPanel) {
        showPreferencesPanel()
    }
}

var snapshotState: Int = 0

private func startPlaying() {
    let cropperStyle = CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!
    syncCropperView(from: cropperStyle)
    fixCropperWindow()
    
    let contentView = ContentView()
        .environment(\.managedObjectContext, persistentContainer.viewContext)
        .environmentObject(displayedWords)
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
    activeCropperWindow()
    if UserDefaults.standard.bool(forKey: IsCloseCropperWhenNotPlayingKey) {
        cropperWindow.close()
    } else {
        cropperWindow.orderFrontRegardless()
    }
    
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
