//
//  AppDelegate.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import Cocoa
import SwiftUI
import Vision
import DataBases
import CoreData
import os
import CryptoKit
import AVFoundation
import Foundation

let logger = Logger()

let systemDefaultMinimumTextHeight: Float = 0.03125

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, NSWindowDelegate {

    let statusData = StatusData(isPlaying: false)

    let textProcessConfig = TextProcessConfig(textRecognitionLevel: .fast, minimumTextHeight: systemDefaultMinimumTextHeight)
    let visualConfig: VisualConfig
        
    override init() {
        // VisualConfig
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfLandscape") == nil { // Notice: don't set it Some(0) by mistake
            UserDefaults.standard.set(20.0, forKey: "visualConfig.fontSizeOfLandscape")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfPortrait") == nil {
            UserDefaults.standard.set(13.0, forKey: "visualConfig.fontSizeOfPortrait")
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
    }
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initContentPanel()
        initCropperWindow()
        initKnownWordsPanel()
        
        constructMenuBar()
        
        allKnownWordsSetCache = getAllKnownWordsSet()
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
    let portraitOnelineNormalItem = NSMenuItem(title: "Portrait OneLine", action: #selector(portraitOnelineNormal), keyEquivalent: "")
    let portraitOnelineMiniItem = NSMenuItem(title: "Portrait OneLine Mini", action: #selector(portraitOnelineMini), keyEquivalent: "")
    let closedWordsItem = NSMenuItem(title: "Closed", action: #selector(closeWords), keyEquivalent: "")
    
    let cropperWindowTitleItem = NSMenuItem.init(title: "Cropper Display Style", action: nil, keyEquivalent: "")
    let strokeBorderCropperWindowItem = NSMenuItem(title: "Stroke Border", action: #selector(strokeBorderCropperWindow), keyEquivalent: "")
    let rectangleCropperWindowItem = NSMenuItem(title: "Rectangle", action: #selector(rectangleCropperWindow), keyEquivalent: "")
    let miniCropperWindowItem = NSMenuItem(title: "Mini", action: #selector(miniCropperWindow), keyEquivalent: "")
    let closeCropperWindowItem = NSMenuItem(title: "Closed", action: #selector(closeCropperWindow), keyEquivalent: "")
    
    let textRecognitionLevelItem = NSMenuItem.init(title: "Text Recognition Level", action: nil, keyEquivalent: "")
    let setTextRecognitionLevelFastItem = NSMenuItem(title: "Fast", action: #selector(setTextRecognitionLevelFast), keyEquivalent: "")
    let setTextRecognitionLevelAccurateItem = NSMenuItem(title: "Accurate", action: #selector(setTextRecognitionLevelAccurate), keyEquivalent: "")
    
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
        menu.addItem(portraitOnelineNormalItem)
        menu.addItem(portraitOnelineMiniItem)
        menu.addItem(closedWordsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        cropperWindowTitleItem.isEnabled = false
        menu.addItem(cropperWindowTitleItem)
        menu.addItem(strokeBorderCropperWindowItem)
        menu.addItem(rectangleCropperWindowItem)
        menu.addItem(miniCropperWindowItem)
        menu.addItem(closeCropperWindowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        textRecognitionLevelItem.isEnabled = false
        menu.addItem(textRecognitionLevelItem)
        menu.addItem(setTextRecognitionLevelFastItem)
        menu.addItem(setTextRecognitionLevelAccurateItem)
        selectTextRecognitionLevel(textProcessConfig.textRecognitionLevel)
        
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

        let showHistoryItem = NSMenuItem(title: "Show Known Words", action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showHistoryItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
        
    var lastNonContentMode: ContentMode? = nil
    @objc func toggleContent() {
        if !statusData.isPlaying {
            statusData.isPlaying = true
            statusItem.button?.image = NSImage(
                systemSymbolName: "square.dashed.inset.fill",
                accessibilityDescription: nil
            )
            toggleItem.title = "Toggle OFF"
            displayedWords.words = []
            startScreenCapture()
            contentPanel.orderFrontRegardless()
            cropperWindow.orderFrontRegardless()
            fixCropperWindow()
            selectWordsPanel(lastNonContentMode ?? .landscapeNormal)
            selectCropperWindow(.strokeBorder)
        }
        else {
            lastNonContentMode = contentMode
            statusData.isPlaying = false
            statusItem.button?.image = NSImage(
                systemSymbolName: "square.dashed",
                accessibilityDescription: nil
            )
            toggleItem.title = "Toggle ON"
            displayedWords.words = []
            stopScreenCapture()
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
    
    @objc func portraitOnelineNormal() {
        selectWordsPanel(.portraitOnelineNormal)
    }
    
    @objc func portraitOnelineMini() {
        selectWordsPanel(.portraitOnelineMini)
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
    
    @objc func setTextRecognitionLevelFast() {
        selectTextRecognitionLevel(.fast)
    }
    
    @objc func setTextRecognitionLevelAccurate() {
        selectTextRecognitionLevel(.accurate)
    }
    
    func selectTextRecognitionLevel(_ theLevel: VNRequestTextRecognitionLevel) {
        textProcessConfig.textRecognitionLevel = theLevel
        switch textProcessConfig.textRecognitionLevel {
        case .fast:
            setTextRecognitionLevelFastItem.state = .on
            setTextRecognitionLevelAccurateItem.state = .off
        case .accurate:
            setTextRecognitionLevelFastItem.state = .off
            setTextRecognitionLevelAccurateItem.state = .on
        @unknown default:
            setTextRecognitionLevelFastItem.state = .on
            setTextRecognitionLevelAccurateItem.state = .off
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
        case portraitOnelineNormal
        case portraitOnelineMini
        case closed
    }
    func initContentPanel() {
        initLandscapeWordsPanel()
        initPortraitWordsPanel()
        initPortraitOnelineWordsPanel()
        
        selectWordsPanel(.landscapeNormal)
    }
    
    func selectWordsPanel(_ theContentMode: ContentMode) {
        contentMode = theContentMode
        switch contentMode {
        case .landscapeNormal:
            landscapeNormalItem.state = .on
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = LandscapeNormalWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
                .environmentObject(textProcessConfig)
            landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = landscapeWordsPanel
            portraitWordsPanel.close()
            portraitOnelineWordsPanel.close()
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .landscapeMini:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .on
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = LandscapeMiniWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
            landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = landscapeWordsPanel
            portraitWordsPanel.close()
            portraitOnelineWordsPanel.close()
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .portraitNormal:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .on
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = PortraitNormalWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
            portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = portraitWordsPanel
            landscapeWordsPanel.close()
            portraitOnelineWordsPanel.close()
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .portraitMini:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .on
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = PortraitMiniWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
            portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = portraitWordsPanel
            landscapeWordsPanel.close()
            portraitOnelineWordsPanel.close()
            contentPanel.orderFrontRegardless()
            // I prefer the shadow effect, BUT it has problem when opacity is lower ( < 0.75 ), especially when landscape
            contentPanel.hasShadow = true
            contentPanel.invalidateShadow()
            
        case .portraitOnelineNormal:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .on
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .off
            let contentView = PortraitOnelineNormalWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
            portraitOnelineWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = portraitOnelineWordsPanel
            landscapeWordsPanel.close()
            portraitWordsPanel.close()
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .portraitOnelineMini:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .on
            closedWordsItem.state = .off
            let contentView = PortraitOnelineMiniWordsView()
                .environment(\.addToKnownWords, addToKnownWords)
                .environment(\.removeFromKnownWords, removeFromKnownWords)
                .environmentObject(visualConfig)
                .environmentObject(displayedWords)
            portraitOnelineWordsPanel.contentView = NSHostingView(rootView: contentView)
            
            contentPanel = portraitOnelineWordsPanel
            landscapeWordsPanel.close()
            portraitWordsPanel.close()
            contentPanel.orderFrontRegardless()
            contentPanel.hasShadow = false
            
        case .closed:
            landscapeNormalItem.state = .off
            landscapeMiniItem.state = .off
            portraitNormalItem.state = .off
            portraitMiniItem.state = .off
            portraitOnelineNormalItem.state = .off
            portraitOnelineMiniItem.state = .off
            closedWordsItem.state = .on
            
            landscapeWordsPanel.close()
            portraitWordsPanel.close()
            portraitOnelineWordsPanel.close()
            
        }
    }
    
    var landscapeWordsPanel: NSPanel!
    func initLandscapeWordsPanel() {
        // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
        landscapeWordsPanel = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 600, height: 200),
            name: "landscapeWordsPanel"
        )
        
        let contentView = LandscapeNormalWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
    }
    
    var portraitWordsPanel: NSPanel!
    func initPortraitWordsPanel() {
        portraitWordsPanel = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 200, height: 600),
            name: "portraitWordsPanel"
        )
                
        let contentView = PortraitNormalWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
    }
    
    var portraitOnelineWordsPanel: NSPanel!
    func initPortraitOnelineWordsPanel() {
        portraitOnelineWordsPanel = ContentPanel.init(
            contentRect: NSRect(x: 100, y: 100, width: 400, height: 300),
            name: "portraitOnelineWordsPanel"
        )
        
        let contentView = PortraitOnelineNormalWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environment(\.removeFromKnownWords, removeFromKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

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
    
    // MARK: - User Defaults
    // avoid Option value for UserDefaults
    // if has no default value, set a default value here
    @objc func resetUserDefaults() {
        UserDefaults.standard.set(20.0, forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(13.0, forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(colorToData(NSColor.orange)!, forKey: "visualConfig.colorOfLandscape")
        UserDefaults.standard.set(colorToData(NSColor.green)!, forKey: "visualConfig.colorOfPortrait")
        UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
        visualConfig.fontSizeOfLandscape = 20.0
        visualConfig.fontSizeOfPortrait = 13.0
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
        portraitOnelineWordsPanel.setFrame(
            NSRect(x: 100, y: 100, width: 400, height: 300),
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
            case .portraitOnelineNormal:
                return visualConfig.fontSizeOfPortrait
            case .portraitOnelineMini:
                return visualConfig.fontSizeOfPortrait
            case .closed:
                return visualConfig.fontSizeOfLandscape
            }
        }()
        let font = NSFont(name: name, size: size) ?? NSFont.systemFont(ofSize: 13.0)

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
        case .portraitOnelineNormal:
            visualConfig.fontSizeOfPortrait = newFont.pointSize
        case .portraitOnelineMini:
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
        case .portraitOnelineNormal:
            visualConfig.colorOfPortrait = sender.color
        case .portraitOnelineMini:
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
    
    func getAllKnownWordsSorted() -> [String] {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \WordStats.word, ascending: true)
        ]
        
        do {
            let results = try context.fetch(fetchRequest)
            let knownWords = results.map { $0.word! }
            return knownWords
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

    // MARK: - AVSession
    let session: AVCaptureSession = AVCaptureSession()
    let screenInput: AVCaptureScreenInput = AVCaptureScreenInput(displayID: CGMainDisplayID())! // todo
    let dataOutput: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
    let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedDataOutput",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    // for testing mp4 file
    let testMovie = false
    let testMovieFileOutput: AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
    // need maually delete for testing.
    let movieUrlString = NSHomeDirectory() + "/Documents/" + "ab.mp4"

    func startScreenCapture() {
        let videoFramesPerSecond = 1 // todo
        screenInput.minFrameDuration = CMTime(seconds: 1 / Double(videoFramesPerSecond), preferredTimescale: 600)
        
        screenInput.cropRect = cropperWindow.frame

//        input.scaleFactor = CGFloat(scaleFactor)
        screenInput.capturesCursor = false
        screenInput.capturesMouseClicks = false

        session.beginConfiguration()
        
        if session.canAddInput(screenInput) {
            session.addInput(screenInput)
        } else {
          print("Could not add video device input to the session")
        }
        
        if testMovie {
            if session.canAddOutput(testMovieFileOutput) {
                session.addOutput(testMovieFileOutput)
                testMovieFileOutput.movieFragmentInterval = .invalid
//                testMovieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodec], for: connection)
            } else {
                print("Could not add movie file output to the session")
            }
        }
        else {
            if session.canAddOutput(dataOutput) {
                session.addOutput(dataOutput)
                // Add a video data output
                dataOutput.alwaysDiscardsLateVideoFrames = true
                //          dataOutput.videoSettings = [
                //            String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
                //          ]
                dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            } else {
                print("Could not add video data output to the session")
            }
            //        let captureConnection = dataOutput.connection(with: .video)
            //        captureConnection?.preferredVideoStabilizationMode = .standard
            //        captureConnection?.videoOrientation = .portrait
            // Always process the frames
            //        captureConnection?.isEnabled = true
        }
        
        session.commitConfiguration()
        
        session.startRunning()
        
        if testMovie {
            let movieUrl = URL.init(fileURLWithPath: movieUrlString)
            testMovieFileOutput.startRecording(to: movieUrl, recordingDelegate: self)
        }
    }

    func stopScreenCapture() {
        if testMovie {
            testMovieFileOutput.stopRecording()
        }

        session.stopRunning()
    }
    
    // for test mp4
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    var sampleBufferCache: CMSampleBuffer? = nil
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if sampleBuffer.imageBuffer == sampleBufferCache?.imageBuffer {
//            logger.info("captureOutput sampleBuffer.imageBuffer == sampleBufferCache?.imageBuffer, so don't do later duplicate works")
            return
        }
        logger.info("captureOutput sampleBuffer.imageBuffer != sampleBufferCache?.imageBuffer, so do heavy cpu works")
        
        sampleBufferCache = sampleBuffer

        requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRecognitionRequest.recognitionLevel = textProcessConfig.textRecognitionLevel
        textRecognitionRequest.minimumTextHeight = textProcessConfig.minimumTextHeight
        textRecognitionRequest.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [unowned self] in
            do {
                try requestHandler?.perform([textRecognitionRequest])
            } catch {
                logger.info("TextRecognize failed: \(error.localizedDescription)")
            }
        }
    }

    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results as? [VNRecognizedTextObservation]
            
            if let results = results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                
                if texts.elementsEqual(lastReconginzedTexts) {
//                    logger.info("RecognizedText texts elementsEqual lastReconginzedTexts, so don't do statistic of words")
                } else {
                    logger.info("text not equal lastReconginzedTexts")
                    // words (filter fixed preset known words) (familiars, unfamiliars)
                    let words = nplSample.process(texts)

                    let knownWords = words.filter { word in
                        allKnownWordsSetCache.contains(word)
                    }
                    logger.info(">>knownWords")
                    print(knownWords)

                    let unKnownWords = words.filter { word in
                        !allKnownWordsSetCache.contains(word)
                    }
                    logger.info(">>unKonwnWords")
                    print(unKnownWords)

                    let prefixUnKownWords = Array(unKnownWords.prefix(maxDisplayedWordsCount))
                    logger.info(">>prefixUnKownWords")
                    print(prefixUnKownWords)
                    
                    withAnimation {
                        displayedWords.words = prefixUnKownWords
                        displayedWords.knownWords = knownWords
                    }
                    
                    lastReconginzedTexts = texts
                }
            }
        }
    }
    
    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!
    
    //    let recognizedText = RecognizedText(texts: [])
    let displayedWords = DisplayedWords(words: [], knownWords: [])
    var lastReconginzedTexts: [String] = []
}

let maxDisplayedWordsCount = 100 // todo: UserDefaults
