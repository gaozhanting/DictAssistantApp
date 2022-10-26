//
//  AVSessionSample.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/16.
//

import Cocoa
import Foundation
import AVFoundation
import Vision
import ScreenCaptureKit

class CaptureEngineStreamOutput: NSObject, SCStreamOutput, SCStreamDelegate {
        
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of outputType: SCStreamOutputType) {
        
        // Return early if the sample buffer is invalid.
        guard sampleBuffer.isValid else { return }
        
        DispatchQueue.main.async {
//            self.dealWith(sampleBuffer: sampleBuffer)
            aVSessionAndTR.dealWith(sampleBuffer: sampleBuffer)

            logger.info("haha>> deal with stream")
        }
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        logger.error("error: \(error.localizedDescription)")
    }
}

let captureEngineStreamOutput = CaptureEngineStreamOutput.init()

//let videoSampleBufferQueue = DispatchQueue(label: "com.example.xxapple-samplecode.VideoSampleBufferQueue")
//let audioSampleBufferQueue = DispatchQueue(label: "com.example.xyapple-samplecode.VideoSampleBufferQueue")


class AVSessionAndTR
//: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate
{
    
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
    let movieUrlString = NSHomeDirectory() + "/Documents/" + "ab.mp4"
    
    private var stream: SCStream?
    func startScreenCapture() {
        SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { (availableContent, error ) in
            DispatchQueue.main.async {
                
                guard let availableContent = availableContent else { fatalError("No shareable content.") }
                
                let availableDisplays = availableContent.displays
                let selectedDisplay = availableDisplays.first
                
                guard let display = selectedDisplay else { fatalError("No display selected.") }
                
                // test
//                let excludedApps = [SCRunningApplication]()
                
                // exclude self app, seems not work
//                let excludedApps = availableContent.applications.filter { app in
//                    Bundle.main.bundleIdentifier == app.bundleIdentifier
//                }
//
//                let filter = SCContentFilter(display: display,
//                                             excludingApplications: excludedApps,
//                                             exceptingWindows: [])
                
                // exclude self app cropper window
                let excludeWindows = availableContent.windows.filter { window in
                    window.windowID == self.cropperWindow.windowNumber
                }
                
                let filter = SCContentFilter(display: display,
                                             excludingWindows: excludeWindows)
                
                let streamConfig = SCStreamConfiguration()
                let maximumFrameRate = UserDefaults.standard.double(forKey: MaximumFrameRateKey)
                streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(maximumFrameRate))
                streamConfig.showsCursor = false
                streamConfig.sourceRect = CGRect(
                    origin: CGPoint(
                        x: self.cropperWindow.frame.origin.x,
                        y: CGFloat(313.0)
//                        y: CGFloat(display.height) - self.cropperWindow.frame.origin.y
                    ),
                    size: self.cropperWindow.frame.size)
//                self.cropperWindow.frame
//                streamConfig.destinationRect = self.cropperWindow.frame
                
                logger.info("dddd...")
                
                do {
                    self.stream = SCStream(filter: filter, configuration: streamConfig, delegate: captureEngineStreamOutput)
                    try self.stream?.addStreamOutput(captureEngineStreamOutput, type: .screen, sampleHandlerQueue: self.videoDataOutputQueue)
                    //                try stream.addStreamOutput(captureEngineStreamOutput, type: .audio, sampleHandlerQueue: audioSampleBufferQueue)
                    self.stream?.startCapture()
//                    { error in
//                        if let error = error {
//                            logger.info("my capture failed: \(error.localizedDescription)") // no error, but func stream not hit !?
//                        } else {
//                            logger.info("my capture failed: error is nil.")
//                        }
//                    }
                } catch {
                    logger.error("Failed to capture: \(error.localizedDescription)")
                }
            }
        }
    }


    func startScreenCapture2() {
        let maximumFrameRate = UserDefaults.standard.double(forKey: MaximumFrameRateKey)
        screenInput.minFrameDuration = CMTime(seconds: Double(1 / maximumFrameRate), preferredTimescale: 600)
        
        screenInput.cropRect = cropperWindow.frame

//        input.scaleFactor = CGFloat(scaleFactor)
        screenInput.capturesCursor = false
        screenInput.capturesMouseClicks = false

        session.beginConfiguration()
//        session.sessionPreset = .hd1920x1080
        
        if session.canAddInput(screenInput) {
            session.addInput(screenInput)
        } else {
            logger.error("Could not add video device input to the session")
        }
        
        if testMovie {
            if session.canAddOutput(testMovieFileOutput) {
                session.addOutput(testMovieFileOutput)
                testMovieFileOutput.movieFragmentInterval = .invalid
//                testMovieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodec], for: connection)
            } else {
                logger.error("Could not add movie file output to the session")
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
//                dataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            } else {
                logger.error("Could not add video data output to the session")
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
            do {
                let movieUrl = URL.init(fileURLWithPath: movieUrlString)
                try FileManager.default.removeItem(at: movieUrl)
            } catch {
                logger.error("remove movieUrl exception caught: \(error.localizedDescription)")
            }

            let movieUrl = URL.init(fileURLWithPath: movieUrlString)
//            testMovieFileOutput.startRecording(to: movieUrl, recordingDelegate: self)
        }
    }

    func stopScreenCapture() {
        if testMovie {
            testMovieFileOutput.stopRecording()
        }

//        session.stopRunning()
        stream?.stopCapture()
    }
    
    // for test mp4
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//    }
    
    var sampleBufferCache: CMSampleBuffer? = nil
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        dealWith(sampleBuffer: sampleBuffer)
    }
    
    func dealWith(sampleBuffer: CMSampleBuffer) {
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

