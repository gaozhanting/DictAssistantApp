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

class AVSessionAndTR: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate {
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
        
        screenInput.cropRect = cropperWindow.frame

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
            testMovieFileOutput.startRecording(to: movieUrl, recordingDelegate: self)
        }
    }

    func stopScreenCapture() {
        if testMovie {
            testMovieFileOutput.stopRecording()
        }

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
        textRecognitionRequest.recognitionLevel = textProcessConfig.textRecognitionLevel
        textRecognitionRequest.minimumTextHeight = textProcessConfig.minimumTextHeight
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
        textProcessConfig: TextProcessConfig,
        cropperWindow: NSWindow!,
        trCallBack: @escaping ([String]) -> Void
    ) {
        self.textProcessConfig = textProcessConfig
        self.cropperWindow = cropperWindow
        self.trCallBack = trCallBack
    }
    let textProcessConfig: TextProcessConfig
    let cropperWindow: NSWindow!
    var trCallBack: ([String]) -> Void
}
