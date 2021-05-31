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

//let smallDictionary = Dictionaries.readSmallDict(from: "small_dictionary.txt")
//let oxfordDictionary = Dictionaries.readOxfordDict(from: "oxford_dictionary.txt")
//
//
let manuallyBasicVocabulary = Vocabularies.read(from: "manaually_basic_vocabulary.txt")
let highSchoolVocabulary = Vocabularies.read(from: "high_school_vocabulary.txt")
let cet4Vocabulary = Vocabularies.read(from: "cet4_vocabulary.txt")
//let cet6Vocabulary = Vocabularies.read(from: "cet6_vocabulary.txt")

//@main
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    // Options
    let recognitionLevel = VNRequestTextRecognitionLevel.fast
    let withTimeInterval = 1.0
    // End Options
    
    let modelData = ModelData()
    let statusData = StatusData()
    let cropData = CropData()
    
    var previousWords: [Word] = []

    var statusBar: StatusBarController?
    var popover = NSPopover.init()
    var wordsWindow: NSPanel!
    var cropperWindow: NSPanel!
    var entryPanel: FloatingPanel!
    
    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.jpg"
    
    // MARK: - Application
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        registerGlobalKeyboardShortcuts()
        
        initCropperWindow()

        let windowStyleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .miniaturizable,
            .utilityWindow,
            .docModalWindow,
            .nonactivatingPanel
        ]
        wordsWindow = NSPanel.init(contentRect: NSMakeRect(700,507,310,600),
                                  styleMask: windowStyleMask,
                                    backing: NSWindow.BackingStoreType.buffered,
                                      defer: false,
                                     screen: NSScreen.main)
        wordsWindow.title = "Words"
        
        let context = persistentContainer.viewContext
        let wordsView = WordsView(modelData: modelData)
            .environment(\.managedObjectContext, context)
        wordsWindow.contentView = NSHostingView(rootView: wordsView)
        wordsWindow.delegate = self
        
        // Create the window and set the content view.
        entryPanel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 30), backing: .buffered, defer: false)

        entryPanel.title = "Floating Panel Title"
        // Create the SwiftUI view that provides the window contents.
        // I've opted to ignore top safe area as well, since we're hiding the traffic icons
        let entryView = EntryView(
            toggle: toggle,
            deleteAllWordStaticstics: deleteAllWordStaticstics,
            statusData: statusData,
            toggleCropper: toggleCropper
        )

        entryPanel.contentView = NSHostingView(rootView: entryView)
        
        statusBar = StatusBarController.init(entryPanel)
    }
    
    func initCropperWindow() {
        cropperWindow = NSPanel.init(
            contentRect: NSRect(x: 0, y: 0, width: 100000, height: 100000),
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .fullSizeContentView],
            backing: NSWindow.BackingStoreType.buffered,
            defer: false,
            screen: NSScreen.main)
        
        // Set this if you want the panel to remember its size/position
        cropperWindow.setFrameAutosaveName("cropper Window")
        
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
        
        let cropView = CropperView(
            cropData: self.cropData
        )
        cropperWindow.contentView = NSHostingView(rootView: cropView)
        cropperWindow.isOpaque = false
        cropperWindow.backgroundColor = NSColor.clear
        cropperWindow.center() // only first time centered
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // When click esc on wordsWindow, should toggle to stop.
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        toggle()
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
                fatalError("Failed to save context: \(error)")
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
            toggle()
        })
        KeyboardShortcuts.onKeyUp(for: .exit, action: { [self] in
            exit()
        })
    }
    
    // MARK: - View Actions
    func exit() {
        NSApplication.shared.terminate(self)
    }

    func toggle() {
        if statusData.isPlaying {
            pause()
        } else {
            start()
        }
        statusData.isPlaying = !statusData.isPlaying
    }
    
    func start() {
        showWordsView()
        startScreenCapture()
    }
    
    func pause() {
        closeWordsView()
        stopScreenCapture()
    }
    
    func showWordsView() {
        wordsWindow.orderFrontRegardless()
    }
    func closeWordsView() {
        wordsWindow.close()
    }
    
    func startScreenCapture() {
        timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: true, block: screenCapture(_:))
        screenCapture(timer) // instant execute one time
    }
    func stopScreenCapture() {
        timer.invalidate()
    }
    
    func showCropper() {
        cropperWindow.orderFrontRegardless()
    }
    func closeCropper() {
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
        arguments.append("-x")
        arguments.append("-a")
        arguments.append("-r")
        arguments.append("-d")
        arguments.append("-o")
        arguments.append("-tjpg") // picture size:  jpg < pdf < png < tiff
//            arguments.append("-t pdf jpg tiff")
        arguments.append("-R 0,50,600,600")
        arguments.append("-R \(cropData.x - 0.5*cropData.width),\(cropData.y - 0.5*cropData.height + 25),\(cropData.width),\(cropData.height)")
//        arguments.append("-D2")
        arguments.append(imageUrlString)

        task.arguments = arguments
        task.terminationHandler = { _ in
            self.textRecognize()
            print("process run complete.")
        }
        
        task.launch()
    }
    
    // MARK: - Text Recogniation
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results as? [VNRecognizedTextObservation]
            
            if let results = results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                withAnimation {
                    modelData.words = Transform.classify(texts)
                }
                if !modelData.words.elementsEqual(previousWords) {
                    statistic(
                        modelData.words
                            .filter { $0.translation != nil }
                            .map { $0.text }
                    )
                    previousWords = modelData.words
                }
            }
        }
    }

    func textRecognize() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [unowned self] in
            do {
                resetRequestHandler()
                try requestHandler?.perform([textRecognitionRequest])
            } catch (_) {
                print("textRecognize failed")
            }
        }
    }
    
    func resetRequestHandler() {
        requestHandler = VNImageRequestHandler(url: URL.init(fileURLWithPath: imageUrlString), options: [:])
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        textRecognitionRequest.recognitionLevel = recognitionLevel
        textRecognitionRequest.minimumTextHeight = 0.0
        textRecognitionRequest.usesLanguageCorrection = true
    }
    
}
