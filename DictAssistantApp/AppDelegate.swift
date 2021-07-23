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
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let statusData = StatusData(isPlaying: false)
    
    // this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
    var visualConfig: VisualConfig!
    var aVSessionAndTR: AVSessionAndTR!
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        phrasesDB = Vocabularies.readToSet(from: "phrases_and_idioms_extracted_from_brief_oxford_dict.txt")
        lemmaDB = LemmaDB.read(from: "lemma.en.txt")
        fixedNoiseVocabulary = makeFixedNoiseVocabulary()
        
        initUserDefaultIfEmpty()
        
        visualConfig = VisualConfig(
            fontSizeOfLandscape: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfLandscape")),
            fontSizeOfPortrait: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfPortrait")),
            colorOfLandscape: dataToColor(UserDefaults.standard.data(forKey: "visualConfig.colorOfLandscape")!)!,
            colorOfPortrait: dataToColor(UserDefaults.standard.data(forKey: "visualConfig.colorOfPortrait")!)!,
            fontName: UserDefaults.standard.string(forKey: "visualConfig.fontName")!
        )
        
        initCropperWindow()
        
        initContentWindow()
        
        initKnownWordsPanel()
        initSettingsPanel()
        
        constructMenuBar()
        
        allKnownWordsSetCache = getAllKnownWordsSet()

        aVSessionAndTR = AVSessionAndTR.init(
            cropperWindow: cropperWindow,
            trCallBack: trCallBack
        )
        
        registerGlobalKey()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Global short cut key
    enum FlowStep {
        case beginSelectCropper
        case beginSelectContent
        case ready
    }
    var flowStep: FlowStep = .beginSelectCropper
    func registerGlobalKey() {
        KeyboardShortcuts.onKeyUp(for: .toggleUnicornMode) { [self] in
            if !statusData.isPlaying {
                switch flowStep {
                case .beginSelectCropper:
                    cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperView())
                    cropperWindow.orderFrontRegardless()

                    flowStep = .beginSelectContent
                    
                case .beginSelectContent:
                    let contentViewWithEnv = attachEnv(AnyView(ContentNormalView()))
                    contentWindow.contentView = NSHostingView(rootView: contentViewWithEnv)
                    contentWindow.orderFrontRegardless()
                    
                    flowStep = .ready
                    
                case .ready:
                    let contentViewWithEnv = attachEnv(AnyView(ContentView()))
                    myPreferShadow()
                    contentWindow.contentView = NSHostingView(rootView: contentViewWithEnv)
                    contentWindow.orderFrontRegardless()
                    
                    switch CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))! {
                    case .closed:
                        cropperWindow.contentView = NSHostingView(rootView: EmptyView())
                        cropperWindow.close()
                    case .rectangle:
                        cropperWindow.contentView = NSHostingView(rootView: RectCropperView())
                        cropperWindow.orderFrontRegardless()
                    }
                    
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
        
        KeyboardShortcuts.onKeyUp(for: .cancelUnicornMode) { [self] in
            if !statusData.isPlaying {
                cropperWindow.close()
                contentWindow.close()
                flowStep = .beginSelectCropper
            } else {
                
            }
        }
    }
    
    // I prefer the shadow effect
    func myPreferShadow() {
        switch ContentStyle(rawValue: UserDefaults.standard.integer(forKey: ContentStyleKey))! {
        case .portraitNormal:
            contentWindow.hasShadow = false
        case .portraitMini:
            contentWindow.hasShadow = true
            contentWindow.invalidateShadow()
        case .landscapeNormal:
            contentWindow.hasShadow = false
        case .landscapeMini:
            contentWindow.hasShadow = false
        }
    }
    
    // MARK: - MenuBar
    let menu = NSMenu()
        
    func constructMenuBar() {
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.dashed",
            accessibilityDescription: nil
        )
        
//        menu.addItem(NSMenuItem.separator())

//        let showFontItem = NSMenuItem(title: "Show Font", action: #selector(showFontPanel(_:)), keyEquivalent: "")
//        let showColorItem = NSMenuItem(title: "Show Color", action: #selector(showColorPanel), keyEquivalent: "")
//        menu.addItem(showFontItem)
//        menu.addItem(showColorItem)
        
//        menu.addItem(NSMenuItem.separator())
//
//        let saveUserDefaultsItem = NSMenuItem(title: "Save Settings", action: #selector(saveAllUserDefaults), keyEquivalent: "")
//        let resetUserDefaultsItem = NSMenuItem(title: "Reset Settings", action: #selector(resetUserDefaults), keyEquivalent: "")
//        menu.addItem(saveUserDefaultsItem)
//        menu.addItem(resetUserDefaultsItem)
        
//        menu.addItem(NSMenuItem.separator())

        let showHistoryItem = NSMenuItem(title: "Show Known Words Panel", action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showHistoryItem)
        
        menu.addItem(NSMenuItem.separator())
        let showSettingsPanelItem = NSMenuItem(title: "Preferences...", action: #selector(showSettingsPanel), keyEquivalent: ",")
        menu.addItem(showSettingsPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    func startPlaying() {
        statusData.isPlaying = true
        cachedDict = [:]
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.dashed.inset.fill",
            accessibilityDescription: nil
        )
        displayedWords.wordCells = []
        aVSessionAndTR.startScreenCapture()
    }
    
    func stopPlaying() {
        statusData.isPlaying = false
        cachedDict = [:]
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.dashed",
            accessibilityDescription: nil
        )
        displayedWords.wordCells = []
        aVSessionAndTR.stopScreenCapture()
    }

    @objc func exit() {
        saveAllUserDefaults()
        NSApplication.shared.terminate(self)
    }
    
    @ViewBuilder
    func attachEnv(_ view: AnyView) -> some View {
        view
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)
    }
    
    var contentWindow: NSPanel!
    func initContentWindow() {
        // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
        contentWindow = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 200, height: 600),
            name: "portraitWordsPanel"
        )

        contentWindow.close()
    }
    
    // MARK: - cropperWindow
    var cropperWindow: NSWindow!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init(
            contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
            name: "cropperWindow"
        )
        
        cropperWindow.close()
    }
    
    // no resizable, not movable
    func fixCropperWindow() {
        // remove .resizable otherwise can't mouse through
        cropperWindow.styleMask = [
            .titled,
            .fullSizeContentView
        ]
        cropperWindow.isMovable = false
        cropperWindow.isMovableByWindowBackground = false
    }
    
    // resizable, movable
    func activeCropperWindow() {
        cropperWindow.styleMask = [
            .titled,
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
    
    // MARK: - Setting Panel
    var settingsPanel: NSPanel!
    func initSettingsPanel() {
        settingsPanel = NSPanel.init(
            contentRect: NSRect(x: 500, y: 100, width: 500, height: 500),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
            ],
            backing: .buffered,
            defer: false
        )
        settingsPanel.setFrameAutosaveName("settingsPanel")
        settingsPanel.title = "Preferences"
        settingsPanel.isReleasedWhenClosed = false
        settingsPanel.toolbarStyle = .preference
        settingsPanel.titlebarAppearsTransparent = true
    }
    
    @objc func showSettingsPanel() {
        let settingsView = SettingsView()
        settingsPanel.contentView = NSHostingView(rootView: settingsView)
        settingsPanel.orderFrontRegardless()
    }

//    // MARK:- Appearance (FontPanel & ColorPanel)
//    @objc func showFontPanel(_ sender: Any?) {
//        let name = visualConfig.fontName
//        let size: CGFloat = {
//            switch contentMode {
//            case .landscapeNormal:
//                return visualConfig.fontSizeOfLandscape
//            case .landscapeMini:
//                return visualConfig.fontSizeOfLandscape
//            case .portraitNormal:
//                return visualConfig.fontSizeOfPortrait
//            case .portraitMini:
//                return visualConfig.fontSizeOfPortrait
//            case .closed:
//                return visualConfig.fontSizeOfLandscape
//            }
//        }()
//        let font = NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: CGFloat(defaultFontSizeOfPortrait))
//
//        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
//
//        NSApplication.shared.activate(ignoringOtherApps: true)
//        NSFontManager.shared.orderFrontFontPanel(sender)
//    }
//
//    // must adding @IBAction; otherwise will not be called when user select fonts from FontPanel
//    @IBAction func changeFont(_ sender: NSFontManager?) {
//        guard let sender = sender else { return assertionFailure() }
//        let newFont = sender.convert(.systemFont(ofSize: 0))
//        visualConfig.fontName = newFont.fontName
//
//        switch contentMode {
//        case .landscapeNormal:
//            visualConfig.fontSizeOfLandscape = newFont.pointSize
//        case .landscapeMini:
//            visualConfig.fontSizeOfLandscape = newFont.pointSize
//        case .portraitNormal:
//            visualConfig.fontSizeOfPortrait = newFont.pointSize
//        case .portraitMini:
//            visualConfig.fontSizeOfPortrait = newFont.pointSize
//        case .closed:
//            visualConfig.fontSizeOfLandscape = newFont.pointSize
//        }
//    }
//
//    @objc func showColorPanel() {
//        let panel = NSColorPanel.shared
//        panel.isRestorable = false
//        panel.delegate = self
//        panel.showsAlpha = true
//
//        panel.setAction(#selector(selectColor))
//        panel.setTarget(self)
//
//        NSApplication.shared.activate(ignoringOtherApps: true)
//        panel.orderFront(self)
//    }
//
//    @IBAction func selectColor(_ sender: NSColorPanel) {
//        switch contentMode {
//        case .landscapeNormal:
//            visualConfig.colorOfLandscape = sender.color
//        case .landscapeMini:
//            visualConfig.colorOfLandscape = sender.color
//        case .portraitNormal:
//            visualConfig.colorOfPortrait = sender.color
//        case .portraitMini:
//            visualConfig.colorOfPortrait = sender.color
//        case .closed:
//            visualConfig.colorOfLandscape = sender.color
//        }
//    }
    
    // MARK:- Core Data (WordStatis)
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WordStatistics")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                allKnownWordsSetCache = getAllKnownWordsSet()
                tagTransAndMutateDisplayedWords()
            } catch {
                logger.info("Failed to save context: \(error.localizedDescription)")
//                fatalError("Failed to save context: \(error)")
            }
        }
    }
    
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
            fatalError("Failed to fetch request: \(error)")
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
                fatalError("Failed to fetch request: \(error)")
            }
        }
        saveContext()
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
                fatalError("Failed to fetch request: \(error)")
            }
        }
        saveContext()
    }
    
    func deleteAllKnownWords() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WordStats")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        } catch {
            fatalError("Failed to clear core data: \(error)")
        }
        saveContext()
    }
    
    // MARK:- Words
    let displayedWords = DisplayedWords(wordCells: [])
    
    var currentWords: [String] = []
    
    func trCallBack(texts: [String]) {
        let words = nplSample.process(texts)
        currentWords = words.filter { !fixedNoiseVocabulary.contains($0) }
        tagTransAndMutateDisplayedWords()
    }
    
    func tagTransAndMutateDisplayedWords() {
        var taggedWordTrans: [WordCell] = []
        for word in currentWords {
            if allKnownWordsSetCache.contains(word) {
                taggedWordTrans.append(WordCell(word: word, isKnown: .known, trans: ""))
            } else {
                if let trans = cachedDictionaryServicesDefine(word) { // Ignore non-dict word
                    taggedWordTrans.append(WordCell(word: word, isKnown: .unKnown, trans: trans))
                }
            }
        }
        
        // only for debuging
        if UserDefaults.standard.object(forKey: IsWithAnimationKey) == nil {
            logger.info("IsWithAnimationKey is nil, impossible!")
        }
        
        let isWithAnimation = UserDefaults.standard.bool(forKey: IsWithAnimationKey)
        
        if isWithAnimation {
            withAnimation {
                displayedWords.wordCells = taggedWordTrans
            }
        }
        else {
            displayedWords.wordCells = taggedWordTrans
        }
    }
    
    var cachedDict: [String: String?] = [:]
    func cachedDictionaryServicesDefine(_ word: String) -> String? {
        if let trans = cachedDict[word] {
            return trans
        }
        let trans = DictionaryServices.define(word)
        cachedDict[word] = trans
        return trans
    }
}
