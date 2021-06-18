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

let manuallyBasicVocabulary = Vocabularies.read(from: "manaually_basic_vocabulary.txt")
let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
//let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

let logger = Logger()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    let recognizedText = RecognizedText(texts: [])
    let statusData = StatusData(isPlaying: false)
    
    let textProcessConfig: TextProcessConfig
    let visualConfig: VisualConfig
    let cropData: CropData
    
    var lastReconginzedTexts: [String] = []

    var statusBar: StatusBarController?
    
    var cropperWindow: NSPanel!
    var contentPanel: NSPanel!
    
    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.jpg"
    var imageDigest: SHA256.Digest? = nil
    
    // MARK: - Application
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerGlobalKeyboardShortcuts()
        
        initContentPanel()
        
        initCropperWindow()

        statusBar = StatusBarController.init(toggleContent)
    }
    
    // avoid Option value for UserDefaults
    // if has no default value, set a default value here
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
            fontName: UserDefaults.standard.string(forKey: "visualConfig.fontName")!
        )
        
        // TextProcessConfig
        if UserDefaults.standard.object(forKey: "textProcessConfig.textRecognitionLevel") == nil {
            // refer source code: enum VNRequestTextRecognitionLevel : Int
            UserDefaults.standard.setValue(1, forKey: "textProcessConfig.textRecognitionLevel")
        }
        if UserDefaults.standard.object(forKey: "textProcessConfig.screenCaptureTimeInterval") == nil {
            UserDefaults.standard.setValue(1.0, forKey: "textProcessConfig.screenCaptureTimeInterval")
        }
        textProcessConfig = TextProcessConfig(
            textRecognitionLevel: VNRequestTextRecognitionLevel(
                rawValue: UserDefaults.standard.integer(forKey: "textProcessConfig.textRecognitionLevel")
            )!,
            screenCaptureTimeInterval: UserDefaults.standard.double(forKey: "textProcessConfig.screenCaptureTimeInterval")
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
        visualConfig.fontName = NSFont.systemFont(ofSize: 0.0).fontName
        
        UserDefaults.standard.set(1, forKey: "textProcessConfig.textRecognitionLevel")
        UserDefaults.standard.set(1.0 , forKey: "textProcessConfig.screenCaptureTimeInterval")
        textProcessConfig.textRecognitionLevel = .fast
        textProcessConfig.screenCaptureTimeInterval = 1.0

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
 
    private func saveAllUserDefaults() {
        UserDefaults.standard.set(visualConfig.miniMode, forKey: "visualConfig.miniMode")
        UserDefaults.standard.set(visualConfig.displayMode.rawValue, forKey: "visualConfig.displayMode")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfLandscape), forKey: "visualConfig.fontSizeOfLandscape")
        UserDefaults.standard.set(Double(visualConfig.fontSizeOfPortrait), forKey: "visualConfig.fontSizeOfPortrait")
        UserDefaults.standard.set(visualConfig.fontName, forKey: "visualConfig.fontName")
        
        UserDefaults.standard.set(textProcessConfig.textRecognitionLevel.rawValue, forKey: "textProcessConfig.textRecognitionLevel")
        UserDefaults.standard.set(Double(textProcessConfig.screenCaptureTimeInterval), forKey: "textProcessConfig.screenCaptureTimeInterval")

        UserDefaults.standard.set(Double(cropData.x), forKey: "cropper.x")
        UserDefaults.standard.set(Double(cropData.y), forKey: "cropper.y")
        UserDefaults.standard.set(Double(cropData.width), forKey: "cropper.width")
        UserDefaults.standard.set(Double(cropData.height), forKey: "cropper.height")
    }
    
    func cropperUp() {
        cropData.y -= cropData.height
        
        contentPanel.setFrame(
            NSMakeRect(
                contentPanel.frame.minX,
                contentPanel.frame.minY + cropData.height,
                contentPanel.frame.width,
                contentPanel.frame.height
            ),
            display: true,
            animate: true)
    }
    
    func cropperDown() {
        cropData.y += cropData.height
        
        contentPanel.setFrame(
            NSMakeRect(
                contentPanel.frame.minX,
                contentPanel.frame.minY - cropData.height,
                contentPanel.frame.width,
                contentPanel.frame.height
            ),
            display: true,
            animate: true)
    }

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
            .environment(\.cropperUp, cropperUp)
            .environment(\.cropperDown, cropperDown)
            .environment(\.toggleContentPanelMiniMode, toggleContentPanelMiniMode)
            .environment(\.restartScreenCaptureWithNewTimeInterval, restartScreenCaptureWithNewTimeInterval)
            .environment(\.toggleScreenCapture, toggleScreenCapture)
            .environment(\.showFonts, showFonts)
            .environment(\.changeFont, changeFont)
            .environment(\.syncContentPanelFromVisualConfig, syncContentPanelFromVisualConfig)
            .environment(\.showContentPanel, showContentPanel)
            .environment(\.closeContentPanel, closeContentPanel)
            .environmentObject(textProcessConfig)
            .environmentObject(visualConfig)
            .environmentObject(statusData)
            .environmentObject(recognizedText)

        contentPanel.contentView = NSHostingView(rootView: contentView)
        contentPanel.delegate = self // for windowShouldClose
    }
    
    func initCropperWindow() {
        cropperWindow = CropperWindow.init()
        let cropView = CropperView()
            .environmentObject(cropData)
        
        cropperWindow.contentView = NSHostingView(rootView: cropView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // When click esc on wordsWindow, should toggle to stop.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        stop()
        return true
    }
    
    // MARK:- Appearance
//    override func changeFont(_ sender: Any?) {
//        
//    }
    
    // Found: {Info.plish/Application is agent (UIElement)} should not set to YES, otherwise FontPanel will not showed
    // And: My App must be the main App (when macOS menu is my app menu), otherwise, you can't see FontPanel when you click icon from ControlViews
    func showFonts(_ sender: Any?) {
//        let name = UserDefaults.standard[.fontName]
//        let size = UserDefaults.standard[.fontSize]
//        let font = NSFont(name: visualConfig.fontName, size: 13.0) ?? NSFont.userFont(ofSize: 13.0)!

//        NSFontManager.shared.setSelectedFont(font, isMultiple: false)
        NSFontManager.shared.orderFrontFontPanel(sender)
//
//        NSFontManager.shared.target = self

//        NSFontPanel.shared.isAccessibilityFrontmost()
//        NSFontPanel.shared.makeKeyAndOrderFront(self)
    }
    
    // must adding @IBAction; otherwise will not be called when user select fonts from FontPanel
    @IBAction func changeFont(_ sender: NSFontManager?) {
        guard let sender = sender else { return assertionFailure() }
        let newFont = sender.convert(.systemFont(ofSize: 0))
        visualConfig.fontName = newFont.fontName
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

    // MARK: - Global Keyboard Shortcuts
    func registerGlobalKeyboardShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .startOrPause, action: { [self] in
            toggleContent()
        })
        KeyboardShortcuts.onKeyUp(for: .exit, action: { [self] in
            exit()
        })
        KeyboardShortcuts.onKeyUp(for: .toggleContentPanelMiniMode, action: { [self] in
            toggleContentPanelMiniMode()
        })
        KeyboardShortcuts.onKeyUp(for: .toggleCropperWindowOpaque, action: { [self] in
            toggleCropperWindowOpaque()
        })
        KeyboardShortcuts.onKeyUp(for: .cropperUp, action: { [self] in
            cropperUp()
        })
        KeyboardShortcuts.onKeyUp(for: .cropperDown, action: { [self] in
            cropperDown()
        })
        KeyboardShortcuts.onKeyUp(for: .resetUserDefaults, action: { [self] in
            resetUserDefaults()
        })
        
    }
    
    // MARK: - View Actions
    func exit() {
        saveAllUserDefaults()
        NSApplication.shared.terminate(self)
    }

    func toggleContent() {
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
    
    private func start() {
        startScreenCapture()
        showContentPanel()
        showCropper()
        statusData.isPlaying = true
    }
    
    private func stop() {
        saveAllUserDefaults()
        stopScreenCapture()
        closeContentPanel()
        closeCropper()
        statusData.isPlaying = false
    }

    func showContentPanel() {
        contentPanel.orderFrontRegardless()
    }
    func closeContentPanel() {
        contentPanel.close()
    }
    
    func startScreenCapture() {
        timer = Timer.scheduledTimer(withTimeInterval: textProcessConfig.screenCaptureTimeInterval, repeats: true, block: screenCapture(_:))
        screenCapture(timer) // instant execute one time
    }
    func stopScreenCapture() {
        timer.invalidate()
    }
    
    func restartScreenCaptureWithNewTimeInterval() {
        stopScreenCapture()
        startScreenCapture()
    }
    
    private func showCropper() {
        cropperWindow.orderFrontRegardless()
    }
    private func closeCropper() {
        cropperWindow.close()
    }
    
    func toggleCropper() {
        if cropperWindow.isVisible {
            closeCropper()
        } else {
            showCropper()
        }
    }

    // MARK: - Screen Capture
    func screenCapture(_ timer: Timer) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-x") // do not play sounds
        arguments.append("-a") // do not include windows attached to selected windows
        arguments.append("-r") // do not add dpi meta data to image
        arguments.append("-d") // display errors to the user graphically
        arguments.append("-o") // in window capture mode, do not capture the shadow of the window
        arguments.append("-tjpg") // picture size:  jpg < pdf < png < tiff
        logger.info("screenCapture -R\(self.cropData.x - 0.5*self.cropData.width),\(self.cropData.y - 0.5*self.cropData.height + 25),\(self.cropData.width),\(self.cropData.height)")
        // Notice there is no space between -R and x; just like -D2
        arguments.append("-R\(cropData.x - 0.5*cropData.width),\(cropData.y - 0.5*cropData.height + 25),\(cropData.width),\(cropData.height)")
//        arguments.append("-D2")
        arguments.append(imageUrlString)

        task.arguments = arguments
        task.terminationHandler = { [self] _ in
            let imageData = FileManager.default.contents(atPath: imageUrlString)!
            let imageDigest = SHA256.hash(data: imageData)
            
            if imageDigest == self.imageDigest {
                logger.info("Current ImageDigest is the same as last ImageDigest. So do nothing next!")
                return
            }
            
            self.imageDigest = imageDigest

            self.textRecognize()
            logger.info("process run complete.")
        }
        
        task.launch()
    }
    
    // MARK: - Text Recogniation
    func textRecognize() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [unowned self] in
            do {
                resetRequestHandler()
                try requestHandler?.perform([textRecognitionRequest])
            } catch {
//                fatalError("TextRecognize failed: \(error)")
                logger.info("TextRecognize failed: \(error.localizedDescription)")
            }
        }
    }
    
    func resetRequestHandler() {
        let imageUrl = URL.init(fileURLWithPath: imageUrlString)
        requestHandler = VNImageRequestHandler(url: imageUrl, options: [:])
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRecognitionRequest.recognitionLevel = textProcessConfig.textRecognitionLevel
        textRecognitionRequest.minimumTextHeight = 0.0
        textRecognitionRequest.usesLanguageCorrection = true
    }
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results as? [VNRecognizedTextObservation]
            
            if let results = results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                
                if textProcessConfig.screenCaptureTimeInterval < 0.5 {
                    recognizedText.texts = texts
                } else {
                    withAnimation {
                        recognizedText.texts = texts
                    }
                }
                
                if !recognizedText.texts.elementsEqual(lastReconginzedTexts) {
                    statistic(recognizedText.words)
                    lastReconginzedTexts = recognizedText.texts
                }
            }
        }
    }
}
