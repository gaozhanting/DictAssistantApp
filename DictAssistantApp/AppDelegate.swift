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

let manuallyBasicVocabulary = Vocabularies.read(from: "manaually_basic_vocabulary.txt")
let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
//let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

let logger = Logger()

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    let recognizedText = RecognizedText(texts: [])
    let statusData = StatusData(isPlaying: false)
    let textProcessConfig = TextProcessConfig()
    let visualConfig: VisualConfig
    var cropData: CropData
    
    var lastReconginzedTexts: [String] = []

    var statusBar: StatusBarController?
    
    var cropperWindow: NSPanel!
    var contentPanel: NSPanel!
    
    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.jpg"
    
    // MARK: - Application
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerGlobalKeyboardShortcuts()
        
        initContentPanel()
        
        initCropperWindow()

        
        statusBar = StatusBarController.init(contentPanel)
    }
    
    // avoid Option value for UserDefaults
    // if has no default value, set a default value here
    override init() {
        // VisualConfig
        if UserDefaults.standard.string(forKey: "visualConfig.displayMode") == nil {
            UserDefaults.standard.set("landscape", forKey: "visualConfig.displayMode")
        }
        visualConfig = VisualConfig(
            displayMode: DisplayMode(
                rawValue: UserDefaults.standard.string(forKey: "visualConfig.displayMode")!
            )!
        )
        
        // CropData
        if UserDefaults.standard.object(forKey: "cropper.x") == nil {
            UserDefaults.standard.set(300, forKey: "cropper.x")
        }
        if UserDefaults.standard.object(forKey: "cropper.y") == nil {
            UserDefaults.standard.set(300, forKey: "cropper.y")
        }
        if UserDefaults.standard.object(forKey: "cropper.width") == nil {
            UserDefaults.standard.set(300, forKey: "cropper.width")
        }
        if UserDefaults.standard.object(forKey: "cropper.height") == nil {
            UserDefaults.standard.set(300, forKey: "cropper.height")
        }
        cropData = CropData(
            x: CGFloat(UserDefaults.standard.double(forKey: "cropper.x")),
            y: CGFloat(UserDefaults.standard.double(forKey: "cropper.y")),
            width: CGFloat(UserDefaults.standard.double(forKey: "cropper.width")),
            height: CGFloat(UserDefaults.standard.double(forKey: "cropper.height"))
        )
    }
    
    private func saveAllUserDefaults() {
        UserDefaults.standard.set(visualConfig.displayMode.rawValue, forKey: "visualConfig.displayMode")
        
        UserDefaults.standard.set(cropData.x, forKey: "cropper.x")
        UserDefaults.standard.set(cropData.y, forKey: "cropper.y")
        UserDefaults.standard.set(cropData.width, forKey: "cropper.width")
        UserDefaults.standard.set(cropData.height, forKey: "cropper.height")
    }

    func initContentPanel() {
        contentPanel = NSPanel.init(
            contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .fullSizeContentView,
                .miniaturizable,
//                .fullScreen,
//                .docModalWindow,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
//            screen: NSScreen.main
        )
        
        // Set this if you want the panel to remember its size/position
        contentPanel.setFrameAutosaveName("ContentPanel")
        
        // Allow the pannel to be on top of almost all other windows
//        contentPanel.isFloatingPanel = true
//        contentPanel.level = .floating
        
        // Allow the pannel to appear in a fullscreen space
        contentPanel.collectionBehavior.insert(.fullScreenAuxiliary)
        
        // While we may set a title for the window, don't show it
//        contentPanel.titleVisibility = .hidden
//        contentPanel.titlebarAppearsTransparent = true
        
        // Since there is no titlebar make the window moveable by click-dragging on the background
        contentPanel.isMovableByWindowBackground = true
        
        // Keep the panel around after closing since I expect the user to open/close it often
        contentPanel.isReleasedWhenClosed = false
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
//        contentPanel.standardWindowButton(.closeButton)?.isHidden = true
//        contentPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
//        contentPanel.standardWindowButton(.zoomButton)?.isHidden = true
//        contentPanel.standardWindowButton(.toolbarButton)?.isHidden = true
        
//        contentPanel.title = "ContentPanel"

        let context = persistentContainer.viewContext
        let contentView = ContentView()
            .environment(\.managedObjectContext, context)
            .environment(\.toggleCropper, toggleCropper)
            .environment(\.toggleContent, toggleContent)
            .environment(\.deleteAllWordStaticstics, deleteAllWordStaticstics)
            .environmentObject(textProcessConfig)
            .environmentObject(visualConfig)
            .environmentObject(statusData)
            .environmentObject(recognizedText)

        contentPanel.contentView = NSHostingView(rootView: contentView)
        contentPanel.titlebarAppearsTransparent = true
        contentPanel.isOpaque = false
        contentPanel.backgroundColor = NSColor.clear
        contentPanel.delegate = self // for windowShouldClose
    }
    
    func initCropperWindow() {
        cropperWindow = NSPanel.init(
            contentRect: NSRect(x: 0, y: 0, width: 100000, height: 100000),
            styleMask: [
                .nonactivatingPanel,
                .titled,
//                .closable, // disable the behavior of pressing esc key to close cropperWindow, because we want it showing the cropper area always.
                .fullSizeContentView,
            ],
            backing: .buffered,
            defer: false
//            screen: NSScreen.main
        )
        
        // Set this if you want the panel to remember its size/position
        cropperWindow.setFrameAutosaveName("CropperWindow")
        
        // Allow the pannel to be on top of almost all other windows
        cropperWindow.isFloatingPanel = true
        cropperWindow.level = .floating
        
        // Allow the pannel to appear in a fullscreen space
        cropperWindow.collectionBehavior.insert(.fullScreenAuxiliary)
        
        // While we may set a title for the window, don't show it
        cropperWindow.titleVisibility = .hidden
        cropperWindow.titlebarAppearsTransparent = true
        
        // Since there is no titlebar make the window moveable by click-dragging on the background
//        cropperWindow.isMovableByWindowBackground = true
        
        // Keep the panel around after closing since I expect the user to open/close it often
        cropperWindow.isReleasedWhenClosed = false
        
        // Activate this if you want the window to hide once it is no longer focused
        //        self.hidesOnDeactivate = true
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
        cropperWindow.standardWindowButton(.closeButton)?.isHidden = true
        cropperWindow.standardWindowButton(.miniaturizeButton)?.isHidden = true
        cropperWindow.standardWindowButton(.zoomButton)?.isHidden = true
        cropperWindow.standardWindowButton(.toolbarButton)?.isHidden = true
        
        let cropView = CropperView()
            .environmentObject(cropData)
        
        cropperWindow.contentView = NSHostingView(rootView: cropView)
        cropperWindow.titlebarAppearsTransparent = true
        cropperWindow.isOpaque = false
        cropperWindow.backgroundColor = NSColor.clear
        cropperWindow.center() // only first time centered
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // When click esc on wordsWindow, should toggle to stop.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        stop()
        return true
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
    
    // Todo: currently don't know how to take side effect when ObservableObject var value changed.
    // Because textProcessConfig.screenCaptureTimeInterva is changing from UI, we don't want to bother to toggle stop&play button, we want it instantly take effect.
    func onConfigScreenCaptureTimeInterval() {
        toggleContent()
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
    
    func toggleCropperStrokeBorder() {
        
    }

    // MARK: - Screen Capture
    func screenCapture(_ timer: Timer) {
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        var arguments = [String]();
        arguments.append("-x")
        arguments.append("-a")
        arguments.append("-r")
        arguments.append("-d")
        arguments.append("-o")
        arguments.append("-tjpg") // picture size:  jpg < pdf < png < tiff
        logger.info("screenCapture -R\(self.cropData.x - 0.5*self.cropData.width),\(self.cropData.y - 0.5*self.cropData.height),\(self.cropData.width),\(self.cropData.height)")
        // Notice there is no space between -R and x; just like -D2
        arguments.append("-R\(cropData.x - 0.5*cropData.width),\(cropData.y - 0.5*cropData.height),\(cropData.width),\(cropData.height)")
//        arguments.append("-D2")
        arguments.append(imageUrlString)

        task.arguments = arguments
        task.terminationHandler = { _ in
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
                
                if textProcessConfig.screenCaptureTimeInterval < 1 {
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
