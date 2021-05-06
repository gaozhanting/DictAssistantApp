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

//@main
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let modelData = ModelData()

    var statusBar: StatusBarController?
    var popover = NSPopover.init()
    var wordsWindow: NSPanel!
    
    var timer: Timer = Timer()

    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!

    var imageUrlString = NSHomeDirectory() + "/Documents/" + "abc.png"
    
    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            self.results = self.textRecognitionRequest.results as? [VNRecognizedTextObservation]

//            if let results = self.results {
//                modelData.words.removeAll(keepingCapacity: true)
//                for observation in results {
//                    let words = observation.topCandidates(1)[0].string
//                    let splitWords = words.components(separatedBy: " ")
//                    for word in splitWords {
//                        let lowercased = word.lowercased()
//                        let trueWord = lowercased.filter { characters.contains($0) }
//                        if !trueWord.isEmpty {
//                            if !modelData.words.contains(trueWord) { // currently ignore performance issue; words count is small.
//                                modelData.words.append(trueWord)
//                            }
//                        }
//                    }
//                }
                
//                print(">>>>")
//                for word in modelData.words {
//                    print(word)
//                }
//                for word in modelData.words {
//                    if smallVocabulary.contains(word) {
//                        translateFromAzure(word)
//                    }
//                }
//                print("modelData words count is \(modelData.words.count)")
            
            if let results = self.results {
                let texts: [String] = results.map { observation in
                    let text: String = observation.topCandidates(1)[0].string
                    return text
                }
                modelData.words = transform(texts)
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
            arguments.append("-R 0,50,600,600")
            arguments.append(imageUrlString)

            task.arguments = arguments
            task.terminationHandler = { _ in
                textRecognize()
                print("process run complete.")
            }
            
            task.launch()
            
//            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: textRecognize(_:))
        }

        func textRecognize() {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [unowned self] in
                do {
                    resetRequestHandler()
                    try self.requestHandler?.perform([self.textRecognitionRequest])
                } catch (_) {
                    print("textRecognize failed")
                }
            }
        }
        
        func startScreenCapture() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: screenCapture(_:))
            screenCapture(timer) // instant execute one time
//            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: screenCapture(_:))
        }
        func stopScreenCapture() {
            timer.invalidate()
        }
        
        func resetRequestHandler() {
            requestHandler = VNImageRequestHandler(url: URL.init(fileURLWithPath: imageUrlString), options: [:])
            textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
            textRecognitionRequest.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            textRecognitionRequest.minimumTextHeight = 0.0
            textRecognitionRequest.usesLanguageCorrection = true
    //        textRecognitionRequest.customWords = []
//            textRecognitionRequest.usesCPUOnly = true
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

