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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, NSWindowDelegate {

    
    let statusData = StatusData(isPlayingInner: false, sideEffectCode: {})

    let textProcessConfig: TextProcessConfig
    let visualConfig: VisualConfig

    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!
        
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
        
        // TextProcessConfig
        if UserDefaults.standard.object(forKey: "textProcessConfig.textRecognitionLevel") == nil {
            // refer source code: enum VNRequestTextRecognitionLevel : Int
            UserDefaults.standard.setValue(1, forKey: "textProcessConfig.textRecognitionLevel")
        }
        textProcessConfig = TextProcessConfig(
            textRecognitionLevelInner: VNRequestTextRecognitionLevel(
                rawValue: UserDefaults.standard.integer(forKey: "textProcessConfig.textRecognitionLevel")
            )!,
            setSideEffectCode: {}
        )
    }
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initContentPanel()
        initCropperWindow()
        initKnownWordsPanel()
        
        statusData.setSideEffectCode = constructMenuBar // Notice: it run setSideEffectCode AFTER isPlayingInner is set
        textProcessConfig.setSideEffectCode = constructMenuBar
        constructMenuBar()
        
        allKnownWordsSetCache = getAllKnownWordsSet()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // MARK: - MenuBar As a side effect code of some state
    func constructMenuBar() {
        // switch menubar button image
        if !statusData.isPlaying {
            statusItem.button?.image = NSImage(systemSymbolName: "circle.dashed", accessibilityDescription: nil)
        } else {
            statusItem.button?.image = NSImage(systemSymbolName: "circle.dashed.inset.fill", accessibilityDescription: nil)
        }
        
        // change item status
        let menu = NSMenu()
        
        let toggleTitle = "Toggle \(statusData.isPlaying ? "OFF" : "ON")"
        menu.addItem(NSMenuItem(title: toggleTitle, action: #selector(toggleContent), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())

        let landscapeNormalItem = NSMenuItem(title: "Landscape Normal", action: #selector(landscapeNormal), keyEquivalent: "")
        let landscapeMiniItem = NSMenuItem(title: "Landscape Mini", action: #selector(landscapeMini), keyEquivalent: "")
        let portraitNormalItem = NSMenuItem(title: "Portrait Normal", action: #selector(portraitNormal), keyEquivalent: "")
        let portraitMiniItem = NSMenuItem(title: "Portrait Mini", action: #selector(portraitMini), keyEquivalent: "")
        let closedWordsItem = NSMenuItem(title: "Closed", action: #selector(closeWords), keyEquivalent: "")
        menu.addItem(landscapeNormalItem)
        menu.addItem(landscapeMiniItem)
        menu.addItem(portraitNormalItem)
        menu.addItem(portraitMiniItem)
        menu.addItem(closedWordsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let cropperWindowTitleItem = NSMenuItem.init(title: "Cropper View Style", action: nil, keyEquivalent: "")
        cropperWindowTitleItem.isEnabled = false
        let strokeBorderCropperWindowItem = NSMenuItem(title: "Stroke Border", action: #selector(stokeBorderCropperWindow), keyEquivalent: "")
        let rectangleCropperWindowItem = NSMenuItem(title: "Rectangle", action: #selector(rectangleCropperWindow), keyEquivalent: "")
        let miniCropperWindowItem = NSMenuItem(title: "Mini", action: #selector(miniCropperWindow), keyEquivalent: "")
        let closeCropperWindowItem = NSMenuItem(title: "Closed", action: #selector(closeCropperWindow), keyEquivalent: "")

        menu.addItem(cropperWindowTitleItem)
        menu.addItem(strokeBorderCropperWindowItem)
        menu.addItem(rectangleCropperWindowItem)
        menu.addItem(miniCropperWindowItem)
        menu.addItem(closeCropperWindowItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let textRecognitionLevelItem = NSMenuItem.init(title: "Text Recognition Level", action: nil, keyEquivalent: "")
        textRecognitionLevelItem.isEnabled = false
        let setTextRecognitionLevelFastItem = NSMenuItem(title: "Fast", action: #selector(setTextRecognitionLevelFast), keyEquivalent: "")
        let setTextRecognitionLevelAccurateItem = NSMenuItem(title: "Accurate", action: #selector(setTextRecognitionLevelAccurate), keyEquivalent: "")
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
        menu.addItem(textRecognitionLevelItem)
        menu.addItem(setTextRecognitionLevelFastItem)
        menu.addItem(setTextRecognitionLevelAccurateItem)

        menu.addItem(NSMenuItem.separator())

        let showFontItem = NSMenuItem(title: "Show Font", action: #selector(showFontPanel(_:)), keyEquivalent: "")
        let showColorItem = NSMenuItem(title: "Show Color", action: #selector(showColorPanel), keyEquivalent: "")
        menu.addItem(showFontItem)
        menu.addItem(showColorItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let saveUserDefaultsItem = NSMenuItem(title: "Save Settings", action: #selector(saveAllUserDefaults), keyEquivalent: "")
        menu.addItem(saveUserDefaultsItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let resetUserDefaultsItem = NSMenuItem(title: "Reset Settings", action: #selector(resetUserDefaults), keyEquivalent: "")
        menu.addItem(resetUserDefaultsItem)
        
        menu.addItem(NSMenuItem.separator())

        let showHistoryItem = NSMenuItem(title: "Show Known Words", action: #selector(showKnownWordsPanel), keyEquivalent: "")
        menu.addItem(showHistoryItem)
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
        
    @objc func toggleContent() {
        if !statusData.isPlaying {
            startScreenCapture()
            contentPanel.orderFrontRegardless()
            cropperWindow.orderFrontRegardless()
            statusData.isPlaying = true
            fixCropperWindow()
        }
        else {
            stopScreenCapture()
            contentPanel.close()
//            cropperWindow.close()
            statusData.isPlaying = false
            activeCropperWindow()
            displayedWords.words = []
        }
    }
    
    @objc func landscapeNormal() {
        let contentView = LandscapeNormalWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
        
        contentPanel = landscapeWordsPanel
        contentMode = .landscape
        portraitWordsPanel.close()
        contentPanel.orderFrontRegardless()
        
        contentPanel.hasShadow = false
    }
    
    @objc func landscapeMini() {
        let contentView = LandscapeMiniWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        landscapeWordsPanel.contentView = NSHostingView(rootView: contentView)
        
        contentPanel = landscapeWordsPanel
        contentMode = .landscape
        portraitWordsPanel.close()
        contentPanel.orderFrontRegardless()
        
        contentPanel.hasShadow = false
    }
    
    @objc func portraitNormal() {
        let contentView = PortraitNormalWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
        
        contentPanel = portraitWordsPanel
        contentMode = .portrait
        landscapeWordsPanel.close()
        contentPanel.orderFrontRegardless()
        
        contentPanel.hasShadow = true
        contentPanel.invalidateShadow()
    }
    
    @objc func portraitMini() {
        let contentView = PortraitMiniWordsView()
            .environment(\.addToKnownWords, addToKnownWords)
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
        
        contentPanel = portraitWordsPanel
        contentMode = .portrait
        landscapeWordsPanel.close()
        contentPanel.orderFrontRegardless()
        
        contentPanel.hasShadow = true
        contentPanel.invalidateShadow()
    }
    
    @objc func closeWords() {
        landscapeWordsPanel.close()
        portraitWordsPanel.close()
    }
    
    // todo: add to setter?! or something (delegate)?!
//    func syncContentPanelFromVisualConfig() {
//        // I prefer the shadow effect, BUT it has problem when opacity is lower ( < 0.75 ), especially when landscape
//        if contentMode == .portrait {
//            // the shadow of the window still exist sometimes!
//            contentPanel.hasShadow = true
//            contentPanel.invalidateShadow()
//        } else {
//            contentPanel.hasShadow = false
//        }
//    }

    @objc func stokeBorderCropperWindow() {
        cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperView())
        cropperWindow.orderFrontRegardless()
        if !statusData.isPlaying {
            activeCropperWindow()
        }
    }
    
    @objc func rectangleCropperWindow() {
        cropperWindow.contentView = NSHostingView(rootView: RectCropperView())
        cropperWindow.orderFrontRegardless()
        if !statusData.isPlaying {
            activeCropperWindow()
        }
    }
    
    @objc func miniCropperWindow() {
        cropperWindow.contentView = NSHostingView(rootView: MiniCropperView())
        cropperWindow.orderFrontRegardless()
        if !statusData.isPlaying {
            activeCropperWindow()
        }
    }
    
    @objc func closeCropperWindow() {
        cropperWindow.contentView = NSHostingView(rootView: ClosedCropperView())
        cropperWindow.orderFrontRegardless()
        if !statusData.isPlaying {
            fixCropperWindow()
        }
    }
    
    @objc func setTextRecognitionLevelFast() {
        textProcessConfig.textRecognitionLevel = .fast
    }
    
    @objc func setTextRecognitionLevelAccurate() {
        textProcessConfig.textRecognitionLevel = .accurate
    }

    @objc func exit() {
        saveAllUserDefaults()
        NSApplication.shared.terminate(self)
    }

    // MARK: - contentPanel
    var contentPanel: NSPanel!
    var contentMode: ContentMode = .landscape
    enum ContentMode {
        case landscape
        case portrait
//        case oneline
    }
    func initContentPanel() {
        initLandscapeWordsPanel()
        initPortraitWordsPanel()
        
        contentPanel = landscapeWordsPanel
        contentMode = .landscape
//        portraitWordsPanel.orderOut(nil)
        portraitWordsPanel.close()
        contentPanel.orderFrontRegardless()
        
        /*
        contentPanel = portraitWordsPanel
        contentMode = .portrait
//        landscapeWordsPanel.orderOut(nil)
        landscapeWordsPanel.close()
        contentPanel.orderFrontRegardless()
        */
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
            .environmentObject(visualConfig)
            .environmentObject(displayedWords)

        portraitWordsPanel.contentView = NSHostingView(rootView: contentView)
    }
    
    // MARK: - cropperWindow
    var cropperWindow: NSWindow!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init(
            contentRect: NSRect(x: 200, y: 100, width: 600, height: 200),
            name: "cropperWindow"
        )
        
        cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperView())
        cropperWindow.orderFrontRegardless()
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
        
        UserDefaults.standard.set(1, forKey: "textProcessConfig.textRecognitionLevel")
        textProcessConfig.textRecognitionLevel = .fast
        
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
    }
 
    @objc func saveAllUserDefaults() {
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfLandscape), forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfPortrait), forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(colorToData(visualConfig.colorOfLandscape)!, forKey: "visualConfig.colorOfLandscape")
        UserDefaults.standard.set(colorToData(visualConfig.colorOfPortrait)!, forKey: "visualConfig.colorOfPortrait")
        UserDefaults.standard.set(visualConfig.fontName, forKey: "visualConfig.fontName")
        
        UserDefaults.standard.set(textProcessConfig.textRecognitionLevel.rawValue, forKey: "textProcessConfig.textRecognitionLevel")
    }

    // MARK:- Appearance (FontPanel & ColorPanel)
    @objc func showFontPanel(_ sender: Any?) {
        let name = visualConfig.fontName
        let size: CGFloat = {
            switch contentMode {
            case .landscape:
                return visualConfig.fontSizeOfLandscape
            case .portrait:
                return visualConfig.fontSizeOfPortrait
            }
        }()
        let font = NSFont(name: name, size: size) ?? NSFont.userFont(ofSize: 13.0)!

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
        case .landscape:
            visualConfig.fontSizeOfLandscape = newFont.pointSize
        case .portrait:
            visualConfig.fontSizeOfPortrait = newFont.pointSize
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
        case .landscape:
            visualConfig.colorOfLandscape = sender.color
        case .portrait:
            visualConfig.colorOfPortrait = sender.color
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
        textRecognitionRequest.minimumTextHeight = 0.0
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
                    let words = TextProcess.extractWords(from: texts)

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
                    }
                    
                    lastReconginzedTexts = texts
                }
            }
        }
    }
    
    //    let recognizedText = RecognizedText(texts: [])
    let displayedWords = DisplayedWords(words: [])
    var lastReconginzedTexts: [String] = []
}

let maxDisplayedWordsCount = 9 // todo: UserDefaults
