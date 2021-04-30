//
//  AppDelegate.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import Cocoa
import SwiftUI
import Vision

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var modelData = ModelData()
    
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
            
//            if let results = results {
//                var displayResults: [((CGPoint, CGPoint, CGPoint, CGPoint), String)] = []
//                for observation in results {
//                    let candidate: VNRecognizedText = observation.topCandidates(1)[0]
//                    let candidateBounds = (observation.bottomLeft, observation.bottomRight, observation.topRight, observation.topLeft)
//                    displayResults.append((candidateBounds, candidate.string))
//                }
//
////                self.imageView.annotationLayer.results = displayResults
//            }
            
            if let results = self.results {
                var transcript: String = ""
                modelData.reset()
                for observation in results {
                    let words = observation.topCandidates(1)[0].string
                    transcript.append(words)
                    modelData.allWords.append(words)
                    transcript.append("\n")
                }
                print(transcript)
//                self.transcriptView.string = transcript
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
            arguments.append("-R 0,100,200,200")
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
                    print("fail")
                }
            }
        }
        
        func startScreenCapture() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: screenCapture(_:))
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
            textRecognitionRequest.usesCPUOnly = true
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
        wordsWindow = NSPanel.init(contentRect: NSMakeRect(1700,500,310,600),
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

