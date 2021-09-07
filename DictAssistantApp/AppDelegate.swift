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
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let statusData = StatusData(isPlaying: false)
    
    // this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
    var aVSessionAndTR: AVSessionAndTR!
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        return // for swiftui preview
        
        phrasesDB = Vocabularies.readToSet(from: "phrases_and_idioms_extracted_from_brief_oxford_dict.txt")
        lemmaDB = LemmaDB.read(from: "lemma.en.txt")
        fixedNoiseVocabulary = makeFixedNoiseVocabulary()

        initAllUserDefaults()

        initCropperWindow()

        initContentWindow()

        initKnownWordsPanel()

        constructMenuBar()

        initToastWindow()

        allKnownWordsSetCache = getAllKnownWordsSet()

        aVSessionAndTR = AVSessionAndTR.init(
            cropperWindow: cropperWindow,
            trCallBack: trCallBack
        )

        registerGlobalKey()

        fixFirstTimeLanuchOddAnimationByImplicitlyShowIt()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - Preferences
    private lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(statusData: statusData),
            AppearancePreferenceViewController(),
            SlotsPreferenceViewController(statusData: statusData, managedObjectContext: persistentContainer.viewContext),
            DictionariesPreferenceViewController()
        ],
        style: .toolbarItems,
        animated: true,
        hidesToolbarForSingleItem: true
    )
    
    @objc func showPreferences() {
        preferencesWindowController.show()
    }
    
    func fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() {
        preferencesWindowController.show(preferencePane: .dictionaries)
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
        KeyboardShortcuts.onKeyUp(for: .toggleUnicornMode) { [self] in
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()
                    let contentViewWithEnv = attachEnv(AnyView(contentView))
                    contentWindow.contentView = NSHostingView(rootView: contentViewWithEnv)
                    contentWindow.orderFrontRegardless()
                    
                    toggleCropperView()
                    
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
            systemSymbolName: "square.dashed",
            accessibilityDescription: nil
        )
        
        let showHistoryItem = NSMenuItem(title: "Show Known Words Panel", action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showHistoryItem)
        
        menu.addItem(NSMenuItem.separator())
        let showSettingsPanelItem = NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
        menu.addItem(showSettingsPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    func startPlaying() {
        toastOn()
        statusData.isPlaying = true
        cachedDict = [:]
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.dashed.inset.fill",
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
            systemSymbolName: "square.dashed",
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
                
        if UserDefaults.standard.bool(forKey: IsShowWindowShadowKey) {
            contentWindow.invalidateShadow()
            contentWindow.hasShadow = true
        } else {
            contentWindow.invalidateShadow()
            contentWindow.hasShadow = false
        }

        contentWindow.close()
    }
    
    // MARK: - cropperWindow
//    var cropperWindow: NSWindow!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init(
            contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
            name: "cropperWindow"
        )
        
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
    
    // MARK:- Core Data (Slots)
//    lazy var slotsPersistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "Slots")
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Unable to load persistent stores: \(error)")
//            }
//        }
//        return container
//    }()
//    
//    func getAllKnownWordsSet2() -> Set<String> {
//        let context = slotsPersistentContainer.viewContext
//        
//        let fetchRequest: NSFetchRequest<Slots> = Slots.fetchRequest()
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
                let taggedWords = tagWords(cleanedWords)
                mutateDisplayedWords(taggedWords)
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
    
    var cleanedWords: [String] = [] // for communication with saveContext
    
    func trCallBack(texts: [String]) {
        let primitiveWords = nplSample.process(texts)
        cleanedWords = primitiveWords.filter { !fixedNoiseVocabulary.contains($0) }
        let taggedWords = tagWords(cleanedWords)
        mutateDisplayedWords(taggedWords)
    }
    
    func tagWords(_ cleanedWords: [String]) -> [WordCell] {
        var taggedWords: [WordCell] = []
        for word in cleanedWords {
            if allKnownWordsSetCache.contains(word) {
                taggedWords.append(WordCell(word: word, isKnown: .known, trans: ""))
            } else {
                if let trans = cachedDictionaryServicesDefine(word) { // Ignore non-dict word
                    taggedWords.append(WordCell(word: word, isKnown: .unKnown, trans: trans))
                } else {
                    // todo: always ???
                    myPrint("!> translation not found from dicts of word: \(word)")
                }
            }
        }
        return taggedWords
    }
     
    func mutateDisplayedWords(_ taggedWordTrans: [WordCell]) {
        // only for debuging
        if UserDefaults.standard.object(forKey: IsWithAnimationKey) == nil {
            logger.info("IsWithAnimationKey is nil, impossible!")
        }
        
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
        }
        
        let portraitCorner = PortraitCorner(rawValue: UserDefaults.standard.integer(forKey: PortraitCornerKey))
        switch portraitCorner {
        case .topLeading:
            return Animation.easeInOut(duration: duration)
        case .topTrailing:
            return Animation.easeInOut(duration: duration)
        case .bottomLeading:
            return Animation.spring(dampingFraction: 0.5).speed(2)
        case .none:
            return nil
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
