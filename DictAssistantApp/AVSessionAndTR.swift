//
//  AVSessionSample.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/16.
//

import Cocoa
import Foundation
import Vision
import ScreenCaptureKit

class AVSessionAndTR : NSObject, SCStreamOutput, SCStreamDelegate {
    let videoDataOutputQueue = DispatchQueue(
        label: "CameraFeedDataOutput",
        qos: .userInitiated,
        attributes: [],
        autoreleaseFrequency: .workItem
    )
    
    private var theStream: SCStream?
    
    func startScreenCapture() {
        SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { (availableContent, error ) in
            DispatchQueue.main.async {
                guard let availableContent = availableContent else {
                    logger.error("No shareable content.")
                    return
                }
                
                let availableDisplays = availableContent.displays
                let selectedDisplay = availableDisplays.first
                
                guard let display = selectedDisplay else {
                    logger.error("No display selected.")
                    return
                }
                
                let excludedApps = availableContent.applications.filter { app in
                    Bundle.main.bundleIdentifier == app.bundleIdentifier
                }

                let filter = SCContentFilter(display: display,
                                             excludingApplications: excludedApps,
                                             exceptingWindows: [])
                
                let streamConfig = SCStreamConfiguration()
                let maximumFrameRate = UserDefaults.standard.integer(forKey: MaximumFrameRateKey)
                streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(maximumFrameRate))
                streamConfig.showsCursor = false
                streamConfig.sourceRect = CGRect(
                    origin: CGPoint(
                        x: self.cropperWindow.frame.origin.x,
                        y: CGFloat(display.height) - self.cropperWindow.frame.maxY // why?
                    ),
                    size: self.cropperWindow.frame.size)
                streamConfig.height = Int(self.cropperWindow.frame.height)
                streamConfig.width = Int(self.cropperWindow.frame.width)
                
                do {
                    self.theStream = SCStream(filter: filter, configuration: streamConfig, delegate: self)
                    try self.theStream?.addStreamOutput(self, type: .screen, sampleHandlerQueue: self.videoDataOutputQueue)
                    self.theStream?.startCapture()
                } catch {
                    logger.error("Failed to capture: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        guard sampleBuffer.isValid else { return }
        
        DispatchQueue.main.async {
            aVSessionAndTR.dealWith(sampleBuffer: sampleBuffer)
        }
    }
    
    var sampleBufferCache: CMSampleBuffer? = nil
    
    private func dealWith(sampleBuffer: CMSampleBuffer) {
        if sampleBuffer.imageBuffer == sampleBufferCache?.imageBuffer {
            return
        }
        
        logger.info("captureOutput sampleBuffer.imageBuffer != sampleBufferCache?.imageBuffer, so do run TR")
        
        sampleBufferCache = sampleBuffer

        requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        textRecognitionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        
        textRecognitionRequest.recognitionLevel = VNRequestTextRecognitionLevel.init(rawValue: UserDefaults.standard.integer(forKey: RecognitionLevelKey))!
        textRecognitionRequest.minimumTextHeight = Float(UserDefaults.standard.double(forKey: MinimumTextHeightKey))
        textRecognitionRequest.usesLanguageCorrection = UserDefaults.standard.bool(forKey: UsesLanguageCorrectionKey)
        textRecognitionRequest.recognitionLanguages = ["en-US"]
        textRecognitionRequest.revision = VNRecognizeTextRequestRevision2
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async { [unowned self] in
            do {
                try requestHandler?.perform([textRecognitionRequest])
            } catch {
                logger.error("TextRecognize failed: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        logger.error("error: \(error.localizedDescription)")
    }

    func stopScreenCapture() {
        theStream?.stopCapture()
    }

    func recognizeTextHandler(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [unowned self] in
            results = textRecognitionRequest.results
            
            trCallBackWithCache()
        }
    }
    
    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!
    
    init(cropperWindow: NSWindow!) {
        self.cropperWindow = cropperWindow
    }
    let cropperWindow: NSWindow!
}

// this ! can make it init at applicationDidFinishLaunching(), otherwise, need at init()
let aVSessionAndTR = AVSessionAndTR.init(
    cropperWindow: cropperWindow
)

