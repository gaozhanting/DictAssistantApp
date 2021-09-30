//
//  AppDelegate.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import Cocoa
import SwiftUI
import DataBases
import CoreData
import CryptoKit
import Foundation
import Vision
import KeyboardShortcuts

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
    var aVSessionAndTR: AVSessionAndTR!
    
    // MARK: - Application
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        return // for swiftui preview
        
        initAllUserDefaultsIfNil()
        
        initCropperWindow()

        initContentWindow()

        combineSomeUserDefaults()
        
        initCustomNoisesPanel()
        
        initCustomPhrasesPanel()
        
        initKnownWordsPanel()
        
        initCustomDictPanel()
        
        initExtraDictionariesPanel()

        initToastWindow()
        
        constructMenuBar()

        aVSessionAndTR = AVSessionAndTR.init(
            cropperWindow: cropperWindow,
            trCallBack: trCallBack
        )

        registerGlobalKey()

        fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() // take 0.36s
        
        initOnboardingPanel()
        
        if !UserDefaults.standard.bool(forKey: IsFinishedOnboardingKey) {
            batchDeleteAllKnownWords()
            batchDeleteAllSlots()
            self.onboarding() // when onboarding end, set IsFinishedOnboardingKey true
        }
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // to learn:
//    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
//        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//        return persistentContainer.viewContext.undoManager
//    }
    
    // MARK: - Global short cut key
    enum FlowStep {
        case beginSelectCropper
        case beginSelectContent
        case ready
    }
    var flowStep: FlowStep = .beginSelectCropper
    func registerGlobalKey() {
        KeyboardShortcuts.onKeyUp(for: .toggleFlowStep) { [self] in
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
    
    // no resizable, not movable
    func fixCropperWindow() {
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
    
    func startPlaying() {
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
    
    func stopPlaying() {
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

    @ViewBuilder
    func attachEnv(_ view: AnyView) -> some View {
        view
            .environmentObject(displayedWords)
    }

    // MARK:- changeFont trigger from FontPanel
    // must adding @IBAction; otherwise will not be called when user select fonts from FontPanel
    @IBAction func changeFont(_ sender: NSFontManager?) {
        guard let sender = sender else { return assertionFailure() }
        let newFont = sender.convert(defaultNSFont)
        
        // hack to resolve the FontPanel issue, .SFNS-Regular can't be found in FontPanel, it is auto changed based on ".AppleSystemUIFont", which is wierd.
        let fontName = newFont.fontName == ".SFNS-Regular" ?
            defaultFontName :
            newFont.fontName
        
        UserDefaults.standard.setValue(fontName, forKey: FontNameKey)
        UserDefaults.standard.setValue(newFont.pointSize, forKey: FontSizeKey)
    }
    
    // MARK:- Words
    
    func trCallBack(texts: [String]) {
        let primitiveWords = nplSample.process(texts)
        
        cleanedWords =
            primitiveWords
            .filter { word in // remove pure numbers
                !word.allSatisfy { c in
                    c.isNumber
                }
            }
            .filter { word in // remove noise
                !fixedNoiseVocabulary.contains(word)
            }
            .filter { word in // remove custom noise
                !allCustomNoisesSet.contains(word)
            }
        
        let taggedWords = tagWords(cleanedWords)
        mutateDisplayedWords(taggedWords)
    }
}

// some global functions, no where to put in ?!

func mutateDisplayedWords(_ taggedWordTrans: [WordCell]) {
    let isWithAnimation = UserDefaults.standard.bool(forKey: IsWithAnimationKey)
    if isWithAnimation {
        withAnimation(whichAnimation()) {
            displayedWords.wordCells = taggedWordTrans
        }
    }
    else {
        displayedWords.wordCells = taggedWordTrans
    }
}

func whichAnimation() -> Animation? {
    let maximumFrameRate = UserDefaults.standard.double(forKey: MaximumFrameRateKey)
    let duration = Double(1 / maximumFrameRate)
    
    let contentStyle = ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))
    if contentStyle == .landscape {
        return Animation.linear(duration: duration)
    } else {
        return Animation.easeInOut(duration: duration)
    }
}

func tagWords(_ cleanedWords: [String]) -> [WordCell] {
    var taggedWords: [WordCell] = []
    for word in cleanedWords {
        if knownWordsSet.contains(word) {
            taggedWords.append(WordCell(word: word, isKnown: .known, trans: "")) // here, not query trans of known words (no matter toggle show or not show known), aim to as an app optimize !
        } else {
            if let trans = cachedDictionaryServicesDefine(word) {
                taggedWords.append(WordCell(word: word, isKnown: .unKnown, trans: trans))
            } else {
                myPrint("!> translation not found from dicts of word: \(word)")
                taggedWords.append(WordCell(word: word, isKnown: .unKnown, trans: ""))
            }
        }
    }
    return taggedWords
}

// MARK: - refresh UI side effect
func refreshContentWhenChangingUseCustomDictMode() {
    cachedDict = [:]
    let taggedWords = tagWords(cleanedWords)
    mutateDisplayedWords(taggedWords)
}
