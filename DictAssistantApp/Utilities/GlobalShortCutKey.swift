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
}

private enum StepPlay {
    case beginSelectCropper
    case beginSelectContent
    case ready
}

private var stepPlay: StepPlay = .beginSelectCropper

func registerGlobalKey() {
    KeyboardShortcuts.onKeyUp(for: .toggleStepPlay) {
        if !statusData.isPlaying {
            switch stepPlay {
            case .beginSelectCropper:
                cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperAnimationView())
                cropperWindow.orderFrontRegardless()

                stepPlay = .beginSelectContent
                
            case .beginSelectContent:
                let emptyView = EmptyView()
                    .background(VisualEffectView(material: .hudWindow))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                contentWindow.contentView = NSHostingView(rootView: emptyView)
                contentWindow.orderFrontRegardless()
                
                stepPlay = .ready
                
            case .ready:
                let contentView = ContentView()
                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                let contentViewWithEnv = attachEnv(AnyView(contentView))
                contentWindow.contentView = NSHostingView(rootView: contentViewWithEnv)
                contentWindow.orderFrontRegardless()
                
                let cropperStyle = CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!
                syncCropperView(from: cropperStyle)
                
                startPlaying()
                
                fixCropperWindow()
                
                stepPlay = .beginSelectCropper
            }
        }
        else {
            cropperWindow.close()
            contentWindow.close()
            
            stopPlaying()
            
            activeCropperWindow()
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
            cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperAnimationView())
            cropperWindow.orderFrontRegardless()
            
            let contentView = ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            let contentViewWithEnv = attachEnv(AnyView(contentView))
            contentWindow.contentView = NSHostingView(rootView: contentViewWithEnv)
            contentWindow.orderFrontRegardless()
            
            let cropperStyle = CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))!
            syncCropperView(from: cropperStyle)
            
            startPlaying()
            
            fixCropperWindow()
            
            stepPlay = .beginSelectCropper
        }
        else {
            contentWindow.close()
            
            stopPlaying()
            
            activeCropperWindow()
        }
    }
}

@ViewBuilder
private func attachEnv(_ view: AnyView) -> some View {
    view
        .environmentObject(displayedWords)
}

private func startPlaying() {
    toastOn()
    statusData.isPlaying = true
    statusItem.button?.image = NSImage(
        systemSymbolName: "d.circle.fill",
        accessibilityDescription: nil
    )
    displayedWords.wordCells = []
    aVSessionAndTR.lastReconginzedTexts = []
    aVSessionAndTR.startScreenCapture()
}

private func stopPlaying() {
    toastOff()
    statusData.isPlaying = false
    statusItem.button?.image = NSImage(
        systemSymbolName: "d.circle",
        accessibilityDescription: nil
    )
    displayedWords.wordCells = []
    aVSessionAndTR.lastReconginzedTexts = []
    aVSessionAndTR.stopScreenCapture()
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
