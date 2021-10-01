//
//  GlobalShortCutKey.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/23.
//

import KeyboardShortcuts
import SwiftUI

extension KeyboardShortcuts.Name {
    static let toggleFlowStep = Self("toggleFlowStep")
    
    static let toggleShowCurrentKnownWords = Self("toggleShowCurrentKnownWords")
    
    static let toggleShowCurrentKnownWordsButWithOpacity0 = Self("toggleShowCurrentKnownWordsButWithOpacity0")
    
    static let toggleConcealTranslation = Self("toggleConcealTranslation")
    
    static let toggleShowCurrentNotFoundWords = Self("toggleShowCurrentNotFoundWords")
}

private enum FlowStep {
    case beginSelectCropper
    case beginSelectContent
    case ready
}

private var flowStep: FlowStep = .beginSelectCropper

func registerGlobalKey() {
    KeyboardShortcuts.onKeyUp(for: .toggleFlowStep) {
        if !statusData.isPlaying {
            switch flowStep {
            case .beginSelectCropper:
                cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperAnimationView())
                cropperWindow.orderFrontRegardless()

                flowStep = .beginSelectContent
                
            case .beginSelectContent:
                let emptyView = EmptyView()
                    .background(VisualEffectView(material: .hudWindow))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                contentWindow.contentView = NSHostingView(rootView: emptyView)
                contentWindow.orderFrontRegardless()
                
                flowStep = .ready
                
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
                
                flowStep = .beginSelectCropper
            }
        }
        else {
            cropperWindow.close()
            contentWindow.close()
            
            stopPlaying()
            
            activeCropperWindow()
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowCurrentKnownWords) {
        if UserDefaults.standard.bool(forKey: IsShowCurrentKnownKey) {
            UserDefaults.standard.setValue(false, forKey: IsShowCurrentKnownKey)
        } else {
            UserDefaults.standard.setValue(true, forKey: IsShowCurrentKnownKey)
        }
    }
    
    KeyboardShortcuts.onKeyUp(for: .toggleShowCurrentKnownWordsButWithOpacity0) {
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
}

@ViewBuilder
private func attachEnv(_ view: AnyView) -> some View {
    view
        .environmentObject(displayedWords)
}

private func startPlaying() {
    toastOn()
    statusData.isPlaying = true
    cachedDict = [:]
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
    cachedDict = [:]
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
