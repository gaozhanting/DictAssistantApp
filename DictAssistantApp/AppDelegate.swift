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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    let statusData = StatusData(isPlaying: false)
    let smallConfig = SmallConfig(fontRate: 0.7, addLineBreak: true, isDisplayKnownWords: false)
    
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
        
        if UserDefaults.standard.object(forKey: TRTextRecognitionLevelKey) == nil {
            UserDefaults.standard.set(1, forKey: TRTextRecognitionLevelKey) // 1 fast, 0 accurate
        }
        if UserDefaults.standard.object(forKey: TRMinimumTextHeightKey) == nil {
            UserDefaults.standard.set(systemDefaultMinimumTextHeight, forKey: TRMinimumTextHeightKey)
        }
        
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfLandscape") == nil { // Notice: don't set it Some(0) by mistake
            UserDefaults.standard.set(defaultFontSizeOfLandscape, forKey: "visualConfig.fontSizeOfLandscape")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfPortrait") == nil {
            UserDefaults.standard.set(defaultFontSizeOfPortrait, forKey: "visualConfig.fontSizeOfPortrait")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontName") == nil {
            UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.colorOfLandscape") == nil {
            UserDefaults.standard.set(colorToData(NSColor.orange)!, forKey: "visualConfig.colorOfLandscape")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.colorOfPortrait") == nil {
            UserDefaults.standard.set(colorToData(NSColor.green)!, forKey: "visualConfig.colorOfPortrait")
        }
        visualConfig = VisualConfig(
            fontSizeOfLandscape: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfLandscape")),
            fontSizeOfPortrait: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfPortrait")),
            colorOfLandscape: dataToColor(UserDefaults.standard.data(forKey: "visualConfig.colorOfLandscape")!)!,
            colorOfPortrait: dataToColor(UserDefaults.standard.data(forKey: "visualConfig.colorOfPortrait")!)!,
            fontName: UserDefaults.standard.string(forKey: "visualConfig.fontName")!
        )
        
        initContentPanel()
        initCropperWindow()
        initKnownWordsPanel()
        initDownloadAndInstallDictsPanel()
        initSettingsPanel()
        
        constructMenuBar()
        
        allKnownWordsSetCache = getAllKnownWordsSet()

        aVSessionAndTR = AVSessionAndTR.init(
            cropperWindow: cropperWindow,
            trCallBack: trCallBack
        )
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - MenuBar
    let menu = NSMenu()
    
    let toggleItem = NSMenuItem(title: "Toggle ON", action: #selector(toggleContent), keyEquivalent: "")

    let landscapeNormalItem = NSMenuItem(title: "Landscape Normal", action: #selector(landscapeNormal), keyEquivalent: "")
    let landscapeMiniItem = NSMenuItem(title: "Landscape Mini", action: #selector(landscapeMini), keyEquivalent: "")
    let portraitNormalItem = NSMenuItem(title: "Portrait Normal", action: #selector(portraitNormal), keyEquivalent: "")
    let portraitMiniItem = NSMenuItem(title: "Portrait Mini", action: #selector(portraitMini), keyEquivalent: "")
    let closedWordsItem = NSMenuItem(title: "Closed", action: #selector(closeWords), keyEquivalent: "")
    
    let cropperWindowTitleItem = NSMenuItem(title: "Cropper Display Style", action: nil, keyEquivalent: "")
    let strokeBorderCropperWindowItem = NSMenuItem(title: "Stroke Border", action: #selector(strokeBorderCropperWindow), keyEquivalent: "")
    let rectangleCropperWindowItem = NSMenuItem(title: "Rectangle", action: #selector(rectangleCropperWindow), keyEquivalent: "")
    let miniCropperWindowItem = NSMenuItem(title: "Mini", action: #selector(miniCropperWindow), keyEquivalent: "")
    let closeCropperWindowItem = NSMenuItem(title: "Closed", action: #selector(closeCropperWindow), keyEquivalent: "")
    
    enum AnimationStyle {
        case withAnimation
        case withoutAnimation
    }
    var animationStyle: AnimationStyle = .withAnimation
    
    let toggleAnimationTitleItem = NSMenuItem(title: "Toggle Animation", action: nil, keyEquivalent: "")
    let withAnimationItem = NSMenuItem(title: "with animation", action: #selector(toggleWithAnimation), keyEquivalent: "")
    let withoutAnimationItem = NSMenuItem(title: "without animation", action: #selector(toggleWithoutAnimation), keyEquivalent: "")
    
    @objc func adjustTextRecognitionMinimumTextHeight() {}
    
    func constructMenuBar() {
        statusItem.button?.image = NSImage(
            systemSymbolName: "square.dashed",
            accessibilityDescription: nil
        )
        
        menu.addItem(toggleItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let wordsDisplayTitleItem = NSMenuItem.init(title: "Words Display Style", action: nil, keyEquivalent: "")
        wordsDisplayTitleItem.isEnabled = false

        menu.addItem(wordsDisplayTitleItem)
        menu.addItem(landscapeNormalItem)
        menu.addItem(landscapeMiniItem)
        menu.addItem(portraitNormalItem)
        menu.addItem(portraitMiniItem)
        menu.addItem(closedWordsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        cropperWindowTitleItem.isEnabled = false
        menu.addItem(cropperWindowTitleItem)
        menu.addItem(strokeBorderCropperWindowItem)
        menu.addItem(rectangleCropperWindowItem)
        menu.addItem(miniCropperWindowItem)
        menu.addItem(closeCropperWindowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        toggleAnimationTitleItem.isEnabled = false
        menu.addItem(toggleAnimationTitleItem)
        menu.addItem(withAnimationItem)
        menu.addItem(withoutAnimationItem)
        selectAnimationStyle(animationStyle)
        
        menu.addItem(NSMenuItem.separator())

        let showFontItem = NSMenuItem(title: "Show Font", action: #selector(showFontPanel(_:)), keyEquivalent: "")
        let showColorItem = NSMenuItem(title: "Show Color", action: #selector(showColorPanel), keyEquivalent: "")
        menu.addItem(showFontItem)
        menu.addItem(showColorItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let saveUserDefaultsItem = NSMenuItem(title: "Save Settings", action: #selector(saveAllUserDefaults), keyEquivalent: "")
        let resetUserDefaultsItem = NSMenuItem(title: "Reset Settings", action: #selector(resetUserDefaults), keyEquivalent: "")
        menu.addItem(saveUserDefaultsItem)
        menu.addItem(resetUserDefaultsItem)
        
        menu.addItem(NSMenuItem.separator())

        let showHistoryItem = NSMenuItem(title: "Show Known Words Panel", action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showHistoryItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let downloadAndInstallDict = NSMenuItem(title: "Show Download and Install Dicts Panel", action: #selector(showDownloadAndInstallDictsPanel), keyEquivalent: "")
        menu.addItem(downloadAndInstallDict)
        
        menu.addItem(NSMenuItem.separator())
        let showSettingsPanelItem = NSMenuItem(title: "Preferences...", action: #selector(showSettingsPanel), keyEquivalent: ",")
        menu.addItem(showSettingsPanelItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    @objc func toggleWithAnimation() {
        selectAnimationStyle(.withAnimation)
    }
    
    @objc func toggleWithoutAnimation() {
        selectAnimationStyle(.withoutAnimation)
    }
    
    func selectAnimationStyle(_ newAnimationStyle: AnimationStyle) {
        animationStyle = newAnimationStyle
        switch animationStyle {
        case .withAnimation:
            withAnimationItem.state = .on
            withoutAnimationItem.state = .off
        case .withoutAnimation:
            withAnimationItem.state = .off
            withoutAnimationItem.state = .on
        }
    }
    
    var lastNonContentMode: ContentMode? = nil
    @objc func toggleContent() {
        if !statusData.isPlaying {
            statusData.isPlaying = true
            cachedDict = [:]
            statusItem.button?.image = NSImage(
                systemSymbolName: "square.dashed.inset.fill",
                accessibilityDescription: nil
            )
            toggleItem.title = "Toggle OFF"
            displayedWords.wordCells = []
            aVSessionAndTR.startScreenCapture()
            contentPanel.orderFrontRegardless()
            cropperWindow.orderFrontRegardless()
            fixCropperWindow()
            selectWordsPanel(lastNonContentMode ?? .landscapeNormal)
            selectCropperWindow(.closed)
        }
        else {
            lastNonContentMode = contentMode
            statusData.isPlaying = false
            cachedDict = [:]
            statusItem.button?.image = NSImage(
                systemSymbolName: "square.dashed",
                accessibilityDescription: nil
            )
            toggleItem.title = "Toggle ON"
            displayedWords.wordCells = []
            aVSessionAndTR.stopScreenCapture()
            contentPanel.close()
            activeCropperWindow()
            selectWordsPanel(.closed)
            selectCropperWindow(.closed)
        }
    }
    
    @objc func landscapeNormal() {
        selectWordsPanel(.landscapeNormal)
    }
    
    @objc func landscapeMini() {
        selectWordsPanel(.landscapeMini)
    }
    
    @objc func portraitNormal() {
        selectWordsPanel(.portraitNormal)
    }

    @objc func portraitMini() {
        selectWordsPanel(.portraitMini)
    }
    
    @objc func closeWords() {
        selectWordsPanel(.closed)
    }
    
    enum CropperStyle {
        case strokeBorder
        case rectangle
        case mini
        case closed
    }
    @objc func strokeBorderCropperWindow() {
        selectCropperWindow(.strokeBorder)
    }
    
    @objc func rectangleCropperWindow() {
        selectCropperWindow(.rectangle)
    }
    
    @objc func miniCropperWindow() {
        selectCropperWindow(.mini)
    }
    
    @objc func closeCropperWindow() {
        selectCropperWindow(.closed)
    }
    
    func selectCropperWindow(_ cropperStyle: CropperStyle) {
        switch cropperStyle {
        case .strokeBorder:
            cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperView())
            cropperWindow.orderFrontRegardless()
            if !statusData.isPlaying {
                activeCropperWindow()
            } else {
                fixCropperWindow()
            }
            strokeBorderCropperWindowItem.state = .on
            rectangleCropperWindowItem.state = .off
            miniCropperWindowItem.state = .off
            closeCropperWindowItem.state = .off
        case .rectangle:
            cropperWindow.contentView = NSHostingView(rootView: RectCropperView())
            cropperWindow.orderFrontRegardless()
            if !statusData.isPlaying {
                activeCropperWindow()
            } else {
                fixCropperWindow()
            }
            strokeBorderCropperWindowItem.state = .off
            rectangleCropperWindowItem.state = .on
            miniCropperWindowItem.state = .off
            closeCropperWindowItem.state = .off
        case .mini:
            cropperWindow.contentView = NSHostingView(rootView: MiniCropperView())
            cropperWindow.orderFrontRegardless()
            if !statusData.isPlaying {
                activeCropperWindow()
            } else {
                fixCropperWindow()
            }
            strokeBorderCropperWindowItem.state = .off
            rectangleCropperWindowItem.state = .off
            miniCropperWindowItem.state = .on
            closeCropperWindowItem.state = .off
        case .closed:
            cropperWindow.contentView = NSHostingView(rootView: ClosedCropperView())
            cropperWindow.orderFrontRegardless()
            fixCropperWindow()
            strokeBorderCropperWindowItem.state = .off
            rectangleCropperWindowItem.state = .off
            miniCropperWindowItem.state = .off
            closeCropperWindowItem.state = .on
        }
    }

    @objc func exit() {
        saveAllUserDefaults()
        NSApplication.shared.terminate(self)
    }

    // MARK: - contentPanel
    var contentPanel: NSPanel!
    var contentMode: ContentMode = .landscapeNormal
    enum ContentMode {
        case landscapeNormal
        case landscapeMini
        case portraitNormal
        case portraitMini
        case closed
    }
    func initContentPanel() {
        initLandscapeWordsPanel()
        initPortraitWordsPanel()
        
        selectWordsPanel(.landscapeNormal)
    }
    
    @ViewBuilder
    func attachEnv(_ view: AnyView) -> some View {
        view
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)
            .environmentObject(smallConfig)
    }
    
    func selectWordsPanel(_ theContentMode: ContentMode) {
        contentMode = theContentMode
        if contentMode != .closed {
            lastNonContentMode = contentMode
        }
        switch contentMode {
        case .landscapeNormal:
            landscapeNormalItem.state = .on
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = attachEnv(AnyView(LandscapeNormalWordsView()))
            landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            portraitWordsPanel.close()
            contentPanel = landscapeWordsPanel
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .landscapeMini:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .on
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = attachEnv(AnyView(LandscapeMiniWordsView()))
            landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            portraitWordsPanel.close()
            contentPanel = landscapeWordsPanel
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .portraitNormal:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .on
            portraitMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = attachEnv(AnyView(PortraitNormalWordsView()))
            portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            landscapeWordsPanel.close()
            contentPanel = portraitWordsPanel
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .portraitMini:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .on
            closedWordsItem.state = .off
            let contentView = attachEnv(AnyView(PortraitMiniWordsView()))
            portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            landscapeWordsPanel.close()
            contentPanel = portraitWordsPanel
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
            // I prefer the shadow effect, BUT it has problem when opacity is lower ( < 0.75 ), especially when landscape
            contentPanel.hasShadow = true
            contentPanel.invalidateShadow()
            
        case .closed:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            closedWordsItem.state = .on
            
            landscapeWordsPanel.close()
            portraitWordsPanel.close()
            
        }
    }
    
    var landscapeWordsPanel: NSPanel!
    func initLandscapeWordsPanel() {
        // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
        landscapeWordsPanel = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 600, height: 200),
            name: "landscapeWordsPanel"
        )
        
        let contentView = attachEnv(AnyView(LandscapeNormalWordsView()))
        landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
    }
    
    var portraitWordsPanel: NSPanel!
    func initPortraitWordsPanel() {
        portraitWordsPanel = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 200, height: 600),
            name: "portraitWordsPanel"
        )
                
        let contentView = attachEnv(AnyView(PortraitNormalWordsView()))
        portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
    }
    
    // MARK: - cropperWindow
    var cropperWindow: NSWindow!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init(
            contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
            name: "cropperWindow"
        )
        
        selectCropperWindow(.strokeBorder)
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
    
    // MARK: - DownloadAndInstallDicts Panel
    var downloadAndInstallDictsPanel: NSPanel!
    func initDownloadAndInstallDictsPanel() {
        downloadAndInstallDictsPanel = NSPanel.init(
            contentRect: NSRect(x: 500, y: 100, width: 600, height: 400),
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
        )
        downloadAndInstallDictsPanel.setFrameAutosaveName("downloadAndInstallDictsPanel")
        
        downloadAndInstallDictsPanel.isReleasedWhenClosed = false
    }
    
    @objc func showDownloadAndInstallDictsPanel() {
        let downloadAndInstallDictsView = DownloadAndInstallDictsView()
        
        downloadAndInstallDictsPanel.contentView = NSHostingView(rootView: downloadAndInstallDictsView)
        downloadAndInstallDictsPanel.orderFrontRegardless()
    }
    
    // MARK: - Setting Panel
    var settingsPanel: NSPanel!
    func initSettingsPanel() {
        settingsPanel = NSPanel.init(
            contentRect: NSRect(x: 500, y: 100, width: 500, height: 300),
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
    
    // MARK: - User Defaults
    // avoid Option value for UserDefaults
    // if has no default value, set a default value here
    @objc func resetUserDefaults() {
        UserDefaults.standard.set(1, forKey: TRTextRecognitionLevelKey)
        UserDefaults.standard.set(systemDefaultMinimumTextHeight, forKey: TRMinimumTextHeightKey)
        
        UserDefaults.standard.set(defaultFontSizeOfLandscape, forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(defaultFontSizeOfPortrait, forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(colorToData(NSColor.orange)!, forKey: "visualConfig.colorOfLandscape")
        UserDefaults.standard.set(colorToData(NSColor.green)!, forKey: "visualConfig.colorOfPortrait")
        UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
        visualConfig.fontSizeOfLandscape = CGFloat(defaultFontSizeOfLandscape)
        visualConfig.fontSizeOfPortrait = CGFloat(defaultFontSizeOfPortrait)
        visualConfig.colorOfLandscape = .orange
        visualConfig.colorOfPortrait = .green
        visualConfig.fontName = NSFont.systemFont(ofSize: 0.0).fontName
                
        landscapeWordsPanel.setFrame(
            NSRect(x: 100, y: 100, width: 600, height: 200),
            display: true,
            animate: true
        )
        portraitWordsPanel.setFrame(
            NSRect(x: 100, y: 100, width: 200, height: 600),
            display: true,
            animate: true
        )
        cropperWindow.setFrame(
            NSRect(x: 300, y: 300, width: 600, height: 200),
            display: true,
            animate: true
        )
    }
 
    @objc func saveAllUserDefaults() {
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfLandscape), forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfPortrait), forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(colorToData(visualConfig.colorOfLandscape)!, forKey: "visualConfig.colorOfLandscape")
        UserDefaults.standard.set(colorToData(visualConfig.colorOfPortrait)!, forKey: "visualConfig.colorOfPortrait")
        UserDefaults.standard.set(visualConfig.fontName, forKey: "visualConfig.fontName")
    }

    // MARK:- Appearance (FontPanel & ColorPanel)
    @objc func showFontPanel(_ sender: Any?) {
        let name = visualConfig.fontName
        let size: CGFloat = {
            switch contentMode {
            case .landscapeNormal:
                return visualConfig.fontSizeOfLandscape
            case .landscapeMini:
                return visualConfig.fontSizeOfLandscape
            case .portraitNormal:
                return visualConfig.fontSizeOfPortrait
            case .portraitMini:
                return visualConfig.fontSizeOfPortrait
            case .closed:
                return visualConfig.fontSizeOfLandscape
            }
        }()
        let font = NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: CGFloat(defaultFontSizeOfPortrait))

        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        NSFontManager.shared.orderFrontFontPanel(sender)
    }
    
    // must adding @IBAction; otherwise will not be called when user select fonts from FontPanel
    @IBAction func changeFont(_ sender: NSFontManager?) {
        guard let sender = sender else { return assertionFailure() }
        let newFont = sender.convert(.systemFont(ofSize: 0))
        visualConfig.fontName = newFont.fontName
        
        switch contentMode {
        case .landscapeNormal:
            visualConfig.fontSizeOfLandscape = newFont.pointSize
        case .landscapeMini:
            visualConfig.fontSizeOfLandscape = newFont.pointSize
        case .portraitNormal:
            visualConfig.fontSizeOfPortrait = newFont.pointSize
        case .portraitMini:
            visualConfig.fontSizeOfPortrait = newFont.pointSize
        case .closed:
            visualConfig.fontSizeOfLandscape = newFont.pointSize
        }
    }
    
    @objc func showColorPanel() {
        let panel = NSColorPanel.shared
        panel.isRestorable = false
        panel.delegate = self
        panel.showsAlpha = true
        
        panel.setAction(#selector(selectColor))
        panel.setTarget(self)
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        panel.orderFront(self)
    }
    
    @IBAction func selectColor(_ sender: NSColorPanel) {
        switch contentMode {
        case .landscapeNormal:
            visualConfig.colorOfLandscape = sender.color
        case .landscapeMini:
            visualConfig.colorOfLandscape = sender.color
        case .portraitNormal:
            visualConfig.colorOfPortrait = sender.color
        case .portraitMini:
            visualConfig.colorOfPortrait = sender.color
        case .closed:
            visualConfig.colorOfLandscape = sender.color
        }
    }
    
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
        
        switch animationStyle {
        case .withAnimation:
            withAnimation {
                displayedWords.wordCells = taggedWordTrans
            }
        case .withoutAnimation:
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
