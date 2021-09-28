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
import Preferences

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    
    // this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
    var aVSessionAndTR: AVSessionAndTR!
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        return // for swiftui preview
        
//        batchInsertFixedPhrases(Array(phrasesDB)) // should preset, where is the data stored ?
            
        initAllUserDefaultsIfNil()
        
        initCropperWindow()

        initContentWindow()

        combineSomeUserDefaults()
        
        initKnownWordsPanel()
        
        initCustomDictPanel()
        
        initCustomPhrasesPanel()
        
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
            deleteAllKnownWords()
            deleteAllSlots()
            onboarding() // when onboarding end, set IsFinishedOnboardingKey true
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
    
    // MARK: - Onboarding
    var onboardingPanel: NSPanel!
    func initOnboardingPanel() {
        onboardingPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 650, height: 530),
            styleMask: [
                .nonactivatingPanel,
                .titled,
            ],
            backing: .buffered,
            defer: false
        )
        
        onboardingPanel.setFrameAutosaveName("onBoardingPanel")
    }
    
    @objc func onboarding() {
        let onboardingView = OnboardingView(pages: OnboardingPage.allCases)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.addMultiToKnownWords, addMultiToKnownWords)
            .environment(\.endOnboarding, endOnboarding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        onboardingPanel.contentView = NSHostingView(rootView: onboardingView)
        onboardingPanel.center()
        onboardingPanel.orderFrontRegardless()
    }
    
    func endOnboarding() {
        onboardingPanel.close()
    }
    
    // MARK: - Preferences
    private lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
            AppearancePreferenceViewController(refreshContentWhenChangingUseCustomDictMode: refreshContentWhenChangingUseCustomDictMode),
            SlotsPreferenceViewController(managedObjectContext: persistentContainer.viewContext),
        ],
        style: .toolbarItems,
        animated: true,
        hidesToolbarForSingleItem: true
    )
    
    @objc func showPreferences() {
        preferencesWindowController.show()
    }
    
    func fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() {
        preferencesWindowController.show(preferencePane: .slots)
        preferencesWindowController.show(preferencePane: .appearance)
        preferencesWindowController.show(preferencePane: .general)
        preferencesWindowController.close()
    }
    
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
                        .environment(\.addMultiEntriesToCustomDict, addMultiEntriesToCustomDict)
                        .environment(\.removeMultiWordsFromCustomDict, removeMultiWordsFromCustomDict)
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
    
    // MARK: - MenuBar
    let menu = NSMenu()
        
    func constructMenuBar() {
        statusItem.button?.image = NSImage(
            systemSymbolName: "d.circle",
            accessibilityDescription: nil
        )
        
        let showSettingsPanelItem = NSMenuItem(title: NSLocalizedString("Preferences...", comment:  ""), action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(showSettingsPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showKnownWordsPanelItem = NSMenuItem(title: NSLocalizedString("Show Known Words Panel", comment: ""), action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showKnownWordsPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showCustomDictPanelItem = NSMenuItem(title: NSLocalizedString("Show Custom Dict Panel", comment: ""), action: #selector(showCustomDictPanel), keyEquivalent: "")
        menu.addItem(showCustomDictPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showCustomPhrasesPanelItem = NSMenuItem(title: NSLocalizedString("Show Custom Phrases Panel", comment: ""), action: #selector(showCustomPhrasesPanel), keyEquivalent: "")
        menu.addItem(showCustomPhrasesPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let showExtraDictionariesItem = NSMenuItem(title: NSLocalizedString("Show Extra Dictionaries Panel", comment: ""), action: #selector(showExtraDictionariesPanel), keyEquivalent: "")
        menu.addItem(showExtraDictionariesItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let helpMenu = NSMenu(title: NSLocalizedString("Help", comment: ""))
        helpMenu.delegate = self
        helpMenu.addItem(withTitle: NSLocalizedString("Show Onboarding Panel", comment: ""), action: #selector(onboarding), keyEquivalent: "")
        helpMenu.addItem(withTitle: NSLocalizedString("Watch Tutorial Video", comment: ""), action: #selector(openTutorialVideoURL), keyEquivalent: "")
        let helpMenuItem = NSMenuItem(title: NSLocalizedString("Help", comment: ""), action: nil, keyEquivalent: "")
        menu.addItem(helpMenuItem)
        menu.setSubmenu(helpMenu, for: helpMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: ""), action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    @objc func openTutorialVideoURL() {
        guard let url = URL(string: "https://www.youtube.com/watch?v=afHqGHDfZKA") else {
            return
        }
        NSWorkspace.shared.open(url)
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

    @objc func exit() {
        NSApplication.shared.terminate(self)
    }
    
    @ViewBuilder
    func attachEnv(_ view: AnyView) -> some View {
        view
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(displayedWords)
    }
    
    // MARK: - Known Words Panel
    var knownWordsPanel: NSPanel!
    func initKnownWordsPanel() {
        knownWordsPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
            //            screen: NSScreen.main
        )
        
        knownWordsPanel.setFrameAutosaveName("knownWordsPanel")
        
        knownWordsPanel.collectionBehavior.insert(.fullScreenAuxiliary)
        knownWordsPanel.isReleasedWhenClosed = false
    }
    
    @objc func showKnownWordsPanel() {
        let knownWordsView = KnownWordsView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.removeMultiFromKnownWords, removeMultiFromKnownWords)
            .environment(\.addMultiToKnownWords, addMultiToKnownWords)

        knownWordsPanel.contentView = NSHostingView(rootView: knownWordsView)
        knownWordsPanel.orderFrontRegardless()
    }
    
    // MARK: - Custom Dict Panel
    var customDictPanel: NSPanel!
    func initCustomDictPanel() {
        customDictPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
            //            screen: NSScreen.main
        )
        
        customDictPanel.setFrameAutosaveName("customDictPanel")
        
        customDictPanel.collectionBehavior.insert(.fullScreenAuxiliary)
        customDictPanel.isReleasedWhenClosed = false
    }
    
    @objc func showCustomDictPanel() {
        let customDictView = CustomDictView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.addMultiEntriesToCustomDict, addMultiEntriesToCustomDict)
            .environment(\.removeMultiWordsFromCustomDict, removeMultiWordsFromCustomDict)
        
        customDictPanel.contentView = NSHostingView(rootView: customDictView)
        customDictPanel.orderFrontRegardless()
    }
    
    // MARK: - Custom Phrases
    var customPhrasesPanel: NSPanel!
    func initCustomPhrasesPanel() {
        customPhrasesPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
            //            screen: NSScreen.main
        )
        
        customPhrasesPanel.setFrameAutosaveName("customPhrasesPanel")
        
        customPhrasesPanel.collectionBehavior.insert(.fullScreenAuxiliary)
        customPhrasesPanel.isReleasedWhenClosed = false
    }
    
    @objc func showCustomPhrasesPanel() {
        let customPhrasesView = CustomPhrasesView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.addMultiCustomPhrases, addMultiCustomPhrases)
            .environment(\.removeMultiCustomPhrases, removeMultiCustomPhrases)
        
        customPhrasesPanel.contentView = NSHostingView(rootView: customPhrasesView)
        customPhrasesPanel.orderFrontRegardless()
    }
    
    // MARK: - Extra Dictionaries Panel
    var extraDictionariesPanel: NSPanel!
    func initExtraDictionariesPanel() {
        extraDictionariesPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 400, height: 600),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
            //            screen: NSScreen.main
        )
        
        extraDictionariesPanel.setFrameAutosaveName("extraDictionariesPanel")
        
        extraDictionariesPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    }
    
    @objc func showExtraDictionariesPanel() {
        let extraDictionariesView = DictionariesView()
        
        extraDictionariesPanel.contentView = NSHostingView(rootView: extraDictionariesView)
        extraDictionariesPanel.orderFrontRegardless()
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
        if isWordInKnownWords(word) {
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
