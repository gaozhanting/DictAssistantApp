//
//  GlobalShortCutKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let toggleStepPlay = Self("toggleStepPlay")
    
    static let toggleShowCurrentKnown = Self("toggleShowCurrentKnown")
    
    static let toggleShowCurrentKnownButWithOpacity0 = Self("toggleShowCurrentKnownButWithOpacity0")
    
    static let toggleConcealTranslation = Self("toggleConcealTranslation")
    
    static let toggleShowCurrentNotFoundWords = Self("toggleShowCurrentNotFoundWords")
    
    static let toggleQuickPlay = Self("toggleQuickPlay")
    
    static let showPhraseInsertPanel = Self("showPhraseInsertPanel")
    
    static let showUpsertEntryPanel = Self("showUpsertEntryPanel")
    
    static let showPreferencesPanel = Self("showPreferencesPanel")
}

private enum StepPlay {
    case begin
    case ready
}

private var stepPlay: StepPlay = .begin

func registerGlobalKey() {
    KeyboardShortcuts.onKeyUp(for: .toggleStepPlay) {
        if !statusData.isPlaying {
            switch stepPlay {
            case .begin:
                cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperAnimationView())
                cropperWindow.orderFrontRegardless()

                let emptyView = EmptyView()
                    .background(VisualEffectView(material: .hudWindow))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                contentWindow.contentView = NSHostingView(rootView: emptyView)
                contentWindow.orderFrontRegardless()
                
                stepPlay = .ready
                
            case .ready:
                startPlaying()
                
                stepPlay = .begin
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
    
    KeyboardShortcuts.onKeyUp(for: .toggleQuickPlay) {
        if !statusData.isPlaying {
            startPlaying()
            
            stepPlay = .begin
        } else {
            stopPlaying()
        }
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
    aVSessionAndTR.lastReconginzedTexts = []
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
    aVSessionAndTR.lastReconginzedTexts = []
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
private func activeCropperWindow() {
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
