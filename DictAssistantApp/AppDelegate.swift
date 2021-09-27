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

let statusData = StatusData(isPlaying: false)

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSMenuDelegate {
    
    // this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
    var aVSessionAndTR: AVSessionAndTR!
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        return // for swiftui preview
            
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

        allKnownWordsSetCache = getAllKnownWordsSet() // take 0.02s for 6000 known words

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
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
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
    
//    var contentWindow: NSPanel!
    func initContentWindow() {
        // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
        contentWindow = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 200, height: 600),
            name: "portraitWordsPanel"
        )
        
        contentWindow.delegate = self
                
        let isShowWindowShadow = UserDefaults.standard.bool(forKey: IsShowWindowShadowKey)
        syncContentWindowShadow(from: isShowWindowShadow)

        contentWindow.close()
    }
    
    // MARK: - cropperWindow
//    var cropperWindow: NSWindow!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init(
            contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
            name: "cropperWindow"
        )
        
        cropperWindow.delegate = self

        cropperWindow.close()
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
    
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        myPrint(">>windowDidMove")
        updateSelectedSlot()
        myPrint("<<updateSelectedSlot windowDidMove")
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        myPrint(">>windowDidResize")
        updateSelectedSlot()
        myPrint("<<updateSelectedSlot windowDidResize")
    }
    
    func updateSelectedSlot() {
        let slots = getAllSlots()
        for slot in slots {
            if slot.isSelected {
                var settings = dataToSettings(slot.settings!)!
                settings.contentFrame = contentWindow.frame
                settings.cropperFrame = cropperWindow.frame
                slot.settings = settingsToData(settings)
                saveContext()
                myPrint("did save slot")
                return
            }
        }
    }
    
    // MARK: - Core Data
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WordStatistics")
        container.loadPersistentStores { description, error in
            if let error = error {
                logger.error("Unable to load persistent stores: \(error.localizedDescription)")
            }
        }
        return container
    }()
    
    func saveContext(_ completionHandler: () -> Void = {}) {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completionHandler()
            } catch {
                logger.info("Failed to save context: \(error.localizedDescription)")
            }
        }
    }
    
    func saveContextWithChangingKnownWordsSideEffect() {
        saveContext {
            allKnownWordsSetCache = getAllKnownWordsSet()
            let taggedWords = tagWords(cleanedWords)
            mutateDisplayedWords(taggedWords)
        }
    }
    
    func saveContextWithChangingCustomDictSideEffect() {
        saveContext {
            cachedDict = [:]
            let taggedWords = tagWords(cleanedWords)
            mutateDisplayedWords(taggedWords)
        }
    }
    
    // MARK: - refresh UI side effect
    func refreshContentWhenChangingUseCustomDictMode() {
        cachedDict = [:]
        let taggedWords = tagWords(cleanedWords)
        mutateDisplayedWords(taggedWords)
    }
    
    // MARK: - Core Data (Slot)
    func getAllSlots() -> [Slot] {
        let context = persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Slot> = Slot.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            return []
        }
    }
    
    // for development, call at applicationDidFinishLaunching
    func deleteAllSlots() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Slot")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        } catch {
            logger.error("Failed to delete all slots: \(error.localizedDescription)")
        }
        saveContext()
    }
    
    // MARK: - Core Data (Custom Phrases) (as complement of phrasesDB)
    func getAllCustomPhrasesSet() -> Set<String> {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let customePhrases = results.map { $0.phrase! }
            return Set(customePhrases)
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            return Set()
        }
    }
    
    func addMultiCustomPhrases(_ phrases: [String]) {
        let context = persistentContainer.viewContext
        
        for phrase in phrases {
            let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    let newCustomPhrase = CustomPhrase(context: context)
                    newCustomPhrase.phrase = phrase
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContext()
    }
    
    func removeMultiCustomPhrases(_ phrases: [String]) {
        let context = persistentContainer.viewContext
        
        for phrase in phrases {
            let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if let result = results.first {
                    context.delete(result)
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContext()
    }
    
    // MARK: - Core Data (Custom Dict)
    func getEntry(of word: String) -> CustomDict? {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                return result
            } else {
                return nil
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            return nil
        }
    }
    
    func addMultiEntriesToCustomDict(entries: [Entry]) {
        let context = persistentContainer.viewContext
        
        for entry in entries {
            let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", entry.word)
            fetchRequest.fetchLimit = 1
            
            do { // todo: how to update core data item?
                let results = try context.fetch(fetchRequest)
                if let result = results.first {
                    context.delete(result)
                }
                let newEntry = CustomDict(context: context)
                newEntry.word = entry.word
                newEntry.trans = entry.trans
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContextWithChangingCustomDictSideEffect()
    }
    
    func removeMultiWordsFromCustomDict(words: [String]) {
        let context = persistentContainer.viewContext

        for word in words {
            let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", word)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if let result = results.first {
                    context.delete(result)
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContextWithChangingCustomDictSideEffect()
    }
    
    // MARK:- Core Data (WordStatistics) (Known Words List)
    var allKnownWordsSetCache: Set<String> = Set.init()
    
    // todo: how to make it effecient?
    func getAllKnownWordsSet() -> Set<String> {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let knownWords = results.map { $0.word! }
            return Set(knownWords)
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            return Set()
        }
    }
    
    func addToKnownWords(_ word: String) {
        addMultiToKnownWords([word])
    }
    
    func addMultiToKnownWords(_ words: [String]) {
        let context = persistentContainer.viewContext
        
        for word in words {
            let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", word)
            fetchRequest.fetchLimit = 1
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    let newWordStatus = WordStats(context: context)
                    newWordStatus.word = word
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContextWithChangingKnownWordsSideEffect()
    }
    
    func removeFromKnownWords(_ word: String) {
        removeMultiFromKnownWords([word])
    }
    
    func removeMultiFromKnownWords(_ words: [String]) {
        let context = persistentContainer.viewContext
        
        for word in words {
            let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "word = %@", word)
            fetchRequest.fetchLimit = 1

            do {
                let results = try context.fetch(fetchRequest)
                if let result = results.first {
                    context.delete(result)
                }
            } catch {
                logger.error("Failed to fetch request: \(error.localizedDescription)")
            }
        }
        saveContextWithChangingKnownWordsSideEffect()
    }
    
    // for development, call at applicationDidFinishLaunching
    func deleteAllKnownWords() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WordStats")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        } catch {
            logger.error("Failed to delete all known words: \(error.localizedDescription)")
        }
        saveContextWithChangingKnownWordsSideEffect()
    }
    
    // MARK:- Words
    let displayedWords = DisplayedWords(wordCells: [])
    
    var cleanedWords: [String] = [] // for communication with saveContext
    
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
    
    func tagWords(_ cleanedWords: [String]) -> [WordCell] {
        var taggedWords: [WordCell] = []
        for word in cleanedWords {
            if allKnownWordsSetCache.contains(word) {
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
     
    func mutateDisplayedWords(_ taggedWordTrans: [WordCell]) {
        if isWithAnimation() {
            withAnimation(whichAnimation()) {
                displayedWords.wordCells = taggedWordTrans
            }
        }
        else {
            displayedWords.wordCells = taggedWordTrans
        }
    }
    
    func isWithAnimation() -> Bool {
        return UserDefaults.standard.bool(forKey: IsWithAnimationKey)
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
    
    var cachedDict: [String: String?] = [:]
    func cachedDictionaryServicesDefine(_ word: String) -> String? {
        if let trans = cachedDict[word] {
            return trans
        }
        let trans = queryDefine(word)
        cachedDict[word] = trans
        return trans
    }
    
    func queryDefine(_ word: String) -> String? {
        let mode = UseCustomDictMode.init(rawValue: UserDefaults.standard.integer(forKey: UseCustomDictModeKey))!
        switch mode {
        case .notUse:
            return DictionaryServices.define(word)
        case .asFirstPriority:
            if let entry = getEntry(of: word) {
                let entryStr = "\(entry.word!)\(entry.trans!)"
                return entryStr
            }
            return DictionaryServices.define(word)
        case .asLastPriority:
            if let define = DictionaryServices.define(word) {
                return define
            }
            if let entry = getEntry(of: word) {
                let entryStr = "\(entry.word!)\(entry.trans!)"
                return entryStr
            }
            return nil
        case .only:
            if let entry = getEntry(of: word) {
                let entryStr = "\(entry.word!)\(entry.trans!)"
                return entryStr
            }
            return nil
        }
    }
}
