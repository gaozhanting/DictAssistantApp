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
import KeyboardShortcuts
import os
import CryptoKit
import AVFoundation
import Foundation

let manuallyBasicVocabulary = Vocabularies.read(from: "manaually_basic_vocabulary.txt")
let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
//let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

let logger = Logger()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    let recognizedText = RecognizedText(texts: [])
    
    let statusData = StatusData(isPlayingInner: false, sideEffectCode: {})

    let textProcessConfig: TextProcessConfig
    let visualConfig: VisualConfig
    let cropData: CropData
    
    var lastReconginzedTexts: [String] = []

    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.jpg"
    var imageDigest: SHA256.Digest? = nil
        
    override init() {
        // VisualConfig
        if UserDefaults.standard.object(forKey: "visualConfig.miniMode") == nil {
            UserDefaults.standard.set(false, forKey: "visualConfig.miniMode")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.displayMode") == nil {
            UserDefaults.standard.set("landscape", forKey: "visualConfig.displayMode")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfLandscape") == nil { // Notice: don't set it Some(0) by mistake
            UserDefaults.standard.set(20.0, forKey: "visualConfig.fontSizeOfLandscape")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontSizeOfPortrait") == nil {
            UserDefaults.standard.set(13.0, forKey: "visualConfig.fontSizeOfPortrait")
        }
        if UserDefaults.standard.object(forKey: "visualConfig.fontName") == nil {
            UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
        }
        visualConfig = VisualConfig(
            miniMode: UserDefaults.standard.bool(forKey: "visualConfig.miniMode"),
            displayMode: DisplayMode(rawValue: UserDefaults.standard.string(forKey: "visualConfig.displayMode")!)!,
            fontSizeOfLandscape: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfLandscape")),
            fontSizeOfPortrait: CGFloat(UserDefaults.standard.double(forKey: "visualConfig.fontSizeOfPortrait")),
            colorOfLandscape: .orange,
            colorOfPortrait: .green,
            fontName: UserDefaults.standard.string(forKey: "visualConfig.fontName")!
        )
        
        // TextProcessConfig
        if UserDefaults.standard.object(forKey: "textProcessConfig.textRecognitionLevel") == nil {
            // refer source code: enum VNRequestTextRecognitionLevel : Int
            UserDefaults.standard.setValue(1, forKey: "textProcessConfig.textRecognitionLevel")
        }
        textProcessConfig = TextProcessConfig(
            textRecognitionLevel: VNRequestTextRecognitionLevel(
                rawValue: UserDefaults.standard.integer(forKey: "textProcessConfig.textRecognitionLevel")
            )!
        )
        
        // CropData
        if UserDefaults.standard.object(forKey: "cropper.x") == nil {
            UserDefaults.standard.set(300.0, forKey: "cropper.x")
        }
        if UserDefaults.standard.object(forKey: "cropper.y") == nil {
            UserDefaults.standard.set(300.0, forKey: "cropper.y")
        }
        if UserDefaults.standard.object(forKey: "cropper.width") == nil {
            UserDefaults.standard.set(300.0, forKey: "cropper.width")
        }
        if UserDefaults.standard.object(forKey: "cropper.height") == nil {
            UserDefaults.standard.set(300.0, forKey: "cropper.height")
        }
        cropData = CropData(
            x: CGFloat(UserDefaults.standard.double(forKey: "cropper.x")),
            y: CGFloat(UserDefaults.standard.double(forKey: "cropper.y")),
            width: CGFloat(UserDefaults.standard.double(forKey: "cropper.width")),
            height: CGFloat(UserDefaults.standard.double(forKey: "cropper.height"))
        )
    }
    
    // MARK: - Application
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initContentPanel()
        initCropperWindow()
        
        statusData.setSideEffectCode = constructMenuBar // Notice: it run setSideEffectCode AFTER isPlayingInner is set
        constructMenuBar()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // When click esc on wordsWindow, should toggle to stop.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        stop()
        return true
    }
    
    // MARK: - MenuBar
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
        
//        menu.addItem(NSMenuItem.separator())
//        let a = NSMenuItem(title: "Closed", action: #selector(emptyMethod), keyEquivalent: "")
//        a.state = .on
//        menu.addItem(a)
//        menu.addItem(NSMenuItem(title: "Mini", action: #selector(emptyMethod), keyEquivalent: ""))
//        menu.addItem(NSMenuItem(title: "Normal", action: #selector(emptyMethod), keyEquivalent: ""))
//        menu.addItem(NSMenuItem.separator())
//        let b = NSMenuItem(title: "Closed", action: #selector(emptyMethod), keyEquivalent: "")
//        b.state = .on
//        menu.addItem(b)
//        menu.addItem(NSMenuItem(title: "Mini", action: #selector(emptyMethod), keyEquivalent: ""))
//        menu.addItem(NSMenuItem(title: "Normal", action: #selector(emptyMethod), keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(exit), keyEquivalent: ""))
        
        statusItem.menu = menu
    }
    
    @objc func emptyMethod() {
    }
    
    // MARK: - Windows & View Actions
    @objc func exit() {
        saveAllUserDefaults()
        NSApplication.shared.terminate(self)
    }

    @objc func toggleContent() {
        if statusData.isPlaying {
            stop()
        } else {
            start()
        }
    }
    
    // when toggle play|stop button on ControlView
    func toggleScreenCapture() {
        if statusData.isPlaying {
            stopScreenCapture()
            statusData.isPlaying = false
        } else {
            statusData.isPlaying = true
            startScreenCapture()
        }
    }
    
    func toggleContentPanelMiniMode() {
        withAnimation {
            visualConfig.miniMode.toggle()
        }
        syncContentPanelFromVisualConfig()
    }
    
    func enterContentPanelMiniMode() {
        withAnimation {
            visualConfig.miniMode = true
        }
        syncContentPanelFromVisualConfig()
    }
    
    // todo: add to setter?! or something (delegate)?!
    func syncContentPanelFromVisualConfig() {
        if visualConfig.miniMode {
            contentPanel.isOpaque = false
            contentPanel.backgroundColor = NSColor.clear
        } else {
            contentPanel.isOpaque = true
            contentPanel.backgroundColor = NSColor.windowBackgroundColor
        }

        // I prefer the shadow effect, BUT it has problem when opacity is lower ( < 0.75 ), especially when landscape
        if visualConfig.displayMode == .portrait && visualConfig.miniMode {
            // the shadow of the window still exist sometimes!
            contentPanel.hasShadow = true
            contentPanel.invalidateShadow()
        } else {
            contentPanel.hasShadow = false
        }
    }
    
    func toggleCropperWindowOpaque() {
        cropperWindow.isOpaque.toggle()
        if cropperWindow.backgroundColor == NSColor.clear {
            cropperWindow.backgroundColor = NSColor.windowBackgroundColor
        } else {
            cropperWindow.backgroundColor = NSColor.clear
        }
    }
    
    func start() {
        startScreenCapture()
        contentPanel.orderFrontRegardless()
        cropperWindow.orderFrontRegardless()
        statusData.isPlaying = true
    }
    
    func stop() {
        saveAllUserDefaults()
        
        stopScreenCapture()
        contentPanel.close()
        cropperWindow.close()
        statusData.isPlaying = false
    }
    
    func toggleCropper() {
        if cropperWindow.isVisible {
            cropperWindow.close()
        } else {
            cropperWindow.orderFrontRegardless()
        }
    }

    
    // MARK: - contentPanel
    var contentPanel: NSPanel!
    func initContentPanel() {
        contentPanel = ContentPanel.init()
        
        syncContentPanelFromVisualConfig()
        
        let context = persistentContainer.viewContext
        let contentView = ContentView()
            .environment(\.managedObjectContext, context)
            .environment(\.toggleCropper, toggleCropper)
            .environment(\.toggleContent, toggleContent)
            .environment(\.deleteAllWordStaticstics, deleteAllWordStaticstics)
            .environment(\.resetUserDefaults, resetUserDefaults)
            .environment(\.toggleContentPanelMiniMode, toggleContentPanelMiniMode)
            .environment(\.toggleScreenCapture, toggleScreenCapture)
            .environment(\.showFonts, showFonts)
            .environment(\.changeFont, changeFont)
            .environment(\.syncContentPanelFromVisualConfig, syncContentPanelFromVisualConfig)
            .environment(\.showColorPanel, showColorPanel)
            .environment(\.enterContentPanelMiniMode, enterContentPanelMiniMode)
            .environmentObject(textProcessConfig)
            .environmentObject(visualConfig)
            .environmentObject(statusData)
            .environmentObject(recognizedText)

        contentPanel.contentView = NSHostingView(rootView: contentView)
        contentPanel.delegate = self // for windowShouldClose
    }
    
    // MARK: - cropperWindow
    var cropperWindow: NSPanel!
    func initCropperWindow() {
        cropperWindow = CropperWindow.init()
        let cropView = CropperView()
            .environmentObject(cropData)
        
        cropperWindow.contentView = NSHostingView(rootView: cropView)
    }
    
    // MARK: - User Defaults
    // avoid Option value for UserDefaults
    // if has no default value, set a default value here
    func resetUserDefaults() {
        UserDefaults.standard.set(false, forKey: "visualConfig.miniMode")
        UserDefaults.standard.set("landscape", forKey: "visualConfig.displayMode")
        UserDefaults.standard.set(20.0, forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(13.0, forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(NSFont.systemFont(ofSize: 0.0).fontName, forKey: "visualConfig.fontName")
        visualConfig.miniMode = false
        visualConfig.displayMode = DisplayMode.landscape
        syncContentPanelFromVisualConfig() // always should call this whenever mutate visual config (todo: make it auto)
        visualConfig.fontSizeOfLandscape = 20.0
        visualConfig.fontSizeOfPortrait = 13.0
        visualConfig.colorOfLandscape = .orange
        visualConfig.colorOfPortrait = .green
        visualConfig.fontName = NSFont.systemFont(ofSize: 0.0).fontName
        
        UserDefaults.standard.set(1, forKey: "textProcessConfig.textRecognitionLevel")
        textProcessConfig.textRecognitionLevel = .fast

        UserDefaults.standard.set(300.0, forKey: "cropper.x")
        UserDefaults.standard.set(300.0, forKey: "cropper.y")
        UserDefaults.standard.set(300.0, forKey: "cropper.width")
        UserDefaults.standard.set(300.0, forKey: "cropper.height")
        cropData.x = 300.0
        cropData.y = 300.0
        cropData.width = 300.0
        cropData.height = 300.0
        
        contentPanel.setFrame(
            NSRect(x: 200, y: 100, width: 300, height: 600),
            display: true,
            animate: true
        )
    }
 
    func saveAllUserDefaults() {
        UserDefaults.standard.set(visualConfig.miniMode, forKey: "visualConfig.miniMode")
        UserDefaults.standard.set(visualConfig.displayMode.rawValue, forKey: "visualConfig.displayMode")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfLandscape), forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfPortrait), forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(visualConfig.fontName, forKey: "visualConfig.fontName")
        
        UserDefaults.standard.set(textProcessConfig.textRecognitionLevel.rawValue, forKey: "textProcessConfig.textRecognitionLevel")

        UserDefaults.standard.set(Double(cropData.x), forKey: "cropper.x")
        UserDefaults.standard.set(Double(cropData.y), forKey: "cropper.y")
        UserDefaults.standard.set(Double(cropData.width), forKey: "cropper.width")
        UserDefaults.standard.set(Double(cropData.height), forKey: "cropper.height")
    }

    // MARK:- Appearance (FontPanel & ColorPanel)

    // Found: {Info.plish/Application is agent (UIElement)} should not set to YES, otherwise FontPanel will not showed
    // And: My App must be the main App (when macOS menu is my app menu), otherwise, you can't see FontPanel when you click icon from ControlViews
    // triggered from font control button; not from font standard menu
    func showFonts(_ sender: Any?) {
        let name = visualConfig.fontName
        let size: CGFloat = {
            switch visualConfig.displayMode {
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
        
        switch visualConfig.displayMode {
        case .landscape:
            visualConfig.fontSizeOfLandscape = newFont.pointSize
        case .portrait:
            visualConfig.fontSizeOfPortrait = newFont.pointSize
        }
    }
    
    func showColorPanel() {
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
        switch visualConfig.displayMode {
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
            } catch {
                logger.info("Failed to save context: \(error.localizedDescription)")
//                fatalError("Failed to save context: \(error)")
            }
        }
    }
    
    func addPresentCount(for word: String) {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newWordStatus = WordStats(context: context)
                newWordStatus.word = word
                newWordStatus.presentCount = 1
            } else {
                if let wordStats = results.first {
                    wordStats.presentCount += 1
                }
            }
        } catch {
            fatalError("Failed to fetch request: \(error)")

        }
    }
    
    func deleteAllWordStaticstics() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WordStats")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
        } catch {
            fatalError("Failed to clear core data: \(error)")
        }
        saveContext()
    }
    
    func statistic(_ words: [String]) -> Void {
        for word in words {
            addPresentCount(for: word)
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
        screenInput.cropRect = CGRect(
            x: cropData.x - 0.5*cropData.width,
            y: 1152 - cropData.y - 0.5*cropData.height - 25, // this test OK!
            width: cropData.width,
            height: cropData.height
        )
        // todo: 1152 get from system (scale ..??)
        
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
    
    var sampleBufferCache: CMSampleBuffer? = nil

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if sampleBuffer.imageBuffer == sampleBufferCache?.imageBuffer {
//            logger.info("captureOutput sampleBuffer.imageBuffer == sampleBufferCache?.imageBuffer, so don't do later duplicate works")
            return
        }
        logger.info("captureOutput sampleBuffer.imageBuffer != sampleBufferCache?.imageBuffer, so do heavey cpu works")
        
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
    
    // for test mp4
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results as? [VNRecognizedTextObservation]
            
            if let results = results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                
                withAnimation {
                    recognizedText.texts = texts
                }
                
                if recognizedText.texts.elementsEqual(lastReconginzedTexts) {
//                    logger.info("RecognizedText texts elementsEqual lastReconginzedTexts, so don't do statistic of words")
                } else {
                    logger.info("Do statistic of words")
                    statistic(recognizedText.words)
                    lastReconginzedTexts = recognizedText.texts
                }
            }
        }
    }

}
