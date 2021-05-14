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
class AppDelegate: NSObject, NSApplicationDelegate {
    // Options
    let recognitionLevel = VNRequestTextRecognitionLevel.fast
    let withTimeInterval = 1.0
    // End Options
    
    let modelData = ModelData()

    var statusBar: StatusBarController?
    var popover = NSPopover.init()
    var wordsWindow: NSPanel!
    
    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.jpg"
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results as? [VNRecognizedTextObservation]
            
            if let results = results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                modelData.words = Transform.classify(texts)
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        func showWordsView() {
            wordsWindow.makeKeyAndOrderFront(nil)
        }
        func closeWordsView() {
            wordsWindow.close()
        }
        
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
//            arguments.append("-R 0,50,600,600")
            arguments.append("-D2")
            arguments.append(imageUrlString)

            task.arguments = arguments
            task.terminationHandler = { _ in
                textRecognize()
                print("process run complete.")
            }
            
            task.launch()
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
        
        func startScreenCapture() {
            timer = Timer.scheduledTimer(withTimeInterval: withTimeInterval, repeats: true, block: screenCapture(_:))
            screenCapture(timer) // instant execute one time
        }
        func stopScreenCapture() {
            timer.invalidate()
        }
        
        func resetRequestHandler() {
            requestHandler = VNImageRequestHandler(url: URL.init(fileURLWithPath: imageUrlString), options: [:])
            textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
            textRecognitionRequest.recognitionLevel = recognitionLevel
            textRecognitionRequest.minimumTextHeight = 0.0
            textRecognitionRequest.usesLanguageCorrection = true
        }
                        
        let popoverView = PopoverView(showWordsView: showWordsView, closeWordsView: closeWordsView, startScreenCapture: startScreenCapture, stopScreenCapture: stopScreenCapture)
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = NSHostingController(rootView: popoverView)
        
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
        
        let wordsView = WordsView(modelData: modelData)
        wordsWindow.contentView = NSHostingView(rootView: wordsView)
        
        statusBar = StatusBarController.init(popover, wordsWindow)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

