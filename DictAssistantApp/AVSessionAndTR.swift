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

func getDisplayID(of window: NSWindow) -> CGDirectDisplayID {
    let screen = window.screen! // nil what case?
    return screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
}

class AVSessionAndTR: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
    var session: AVCaptureSession? = nil
    var screenInput: AVCaptureScreenInput? = nil

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

    func startScreenCapture() {
        session = AVCaptureSession()
        guard let session = session else {
            print("session creation failed")
            return
        }
        
        let displayID = getDisplayID(of: cropperWindow!)
        screenInput = AVCaptureScreenInput(displayID: displayID)!
//        screenInput = AVCaptureScreenInput(displayID: CGMainDisplayID())!
        guard let screenInput = screenInput else {
            print("screenInput creation failed")
            return
        }
        
        let videoFramesPerSecond = 1 // todo

        screenInput.minFrameDuration = CMTime(seconds: 1 / Double(videoFramesPerSecond), preferredTimescale: 600)
        
        let cropperWindowFrame = cropperWindow.frame
        print(">>cropperWindowFrame: \(cropperWindowFrame)")
        if displayID == CGMainDisplayID() {
            screenInput.cropRect = cropperWindowFrame // !!! this x should not be negative when cropperWindow in second display monitor !!
        } else { // get the arrangement of multi monitors??!! Is there a API?
            let c = cropperWindowFrame
            let width = NSScreen.screens[1].frame.size.width
            screenInput.cropRect = CGRect.init(
                origin: CGPoint(
                    x: c.origin.x + width,
                    y: c.origin.y),
                size: CGSize(
                    width: c.size.width,
                    height: c.size.height))
        }
        print(">>screenInput.cropRect: \(screenInput.cropRect)")

//        input.scaleFactor = CGFloat(scaleFactor)
        screenInput.capturesCursor = false
        screenInput.capturesMouseClicks = false

        session.beginConfiguration()
        
        if session.canAddInput(screenInput) {
            session.addInput(screenInput)
        } else {
          myPrint("Could not add video device input to the session")
        }
        
        if testMovie {
            if session.canAddOutput(testMovieFileOutput) {
                session.addOutput(testMovieFileOutput)
                testMovieFileOutput.movieFragmentInterval = .invalid
//                testMovieFileOutput.setOutputSettings([AVVideoCodecKey: videoCodec], for: connection)
            } else {
                myPrint("Could not add movie file output to the session")
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
                myPrint("Could not add video data output to the session")
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
            do {
                try FileManager.default.removeItem(at: movieUrl)
            } catch {
                logger.info("remove movieUrl exception caught: \(error.localizedDescription)")
            }
            testMovieFileOutput.startRecording(to: movieUrl, recordingDelegate: self)
        }
    }

    func stopScreenCapture() {
        guard let session = session else {
            print("session is nil")
            return
        }
        
        if testMovie {
            testMovieFileOutput.stopRecording()
            session.removeOutput(testMovieFileOutput)
        }

        session.removeOutput(dataOutput)
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
        
        let textRecognitionLevel = UserDefaults.standard.integer(forKey: TRTextRecognitionLevelKey)
        let textRecognitionLevelE = VNRequestTextRecognitionLevel.init(rawValue: textRecognitionLevel)
        let minimumTextHeight = UserDefaults.standard.double(forKey: TRMinimumTextHeightKey)
//        myPrint(">>>textRecognitionLevel: \(textRecognitionLevel)")
//        myPrint(">>>minimumTextHeight: \(minimumTextHeight)")
        if let textRecognitionLevelE = textRecognitionLevelE {
//            myPrint(">>>textRecognitionLevelE: \(textRecognitionLevelE.rawValue)")
            textRecognitionRequest.recognitionLevel = textRecognitionLevelE
        } else { // never this case, because we init it when launch app.
            logger.info("textRecognitionLevelE is nil, impossible!")
            textRecognitionRequest.recognitionLevel = .fast
        }
        textRecognitionRequest.minimumTextHeight = Float(minimumTextHeight)
        
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
                    
                    trCallBack(texts)

                    lastReconginzedTexts = texts
                }
            }
        }
    }
    
    var results: [VNRecognizedTextObservation]?
    var requestHandler: VNImageRequestHandler?
    var textRecognitionRequest: VNRecognizeTextRequest!
    
    var lastReconginzedTexts: [String] = []
    
    init(
        cropperWindow: NSWindow!,
        trCallBack: @escaping ([String]) -> Void
    ) {
        self.cropperWindow = cropperWindow
        self.trCallBack = trCallBack
    }
    let cropperWindow: NSWindow!
    var trCallBack: ([String]) -> Void
}
