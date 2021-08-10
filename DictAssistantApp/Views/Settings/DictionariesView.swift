//
//  DictionariesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/14.
//

import SwiftUI
import Preferences

struct DictionariesView: View {
    var body: some View {
        Preferences.Container(contentWidth: settingPanelWidth) {
            Preferences.Section(title: "Dictionaries:") {
                ListItem(
                    dictName: "牛津简明英汉袖珍辞典 (zip: 7.7M) (file: 15.6M)",
                    dictLicense: "GNU General Public License",
                    dictFileName: "oxfordjm-ec.dictionary",
                    downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/oxfordjm-ec.dictionary.zip")!
                )
                    .listRowBackground(Color.secondary)
                ListItem(
                    dictName: "牛津英汉双解美化版 (zip: 18.9M) (file: 23.3M)",
                    dictLicense: "GNU General Public License",
                    dictFileName: "mac-oxford-gb-formated.dictionary",
                    downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/mac-oxford-gb-formated.dictionary.zip")!)
                    .listRowBackground(Color.secondary.opacity(0.5))
                ListItem(
                    dictName: "Collins Cobuild 5 (zip: 15M) (file: 18.7M)",
                    dictLicense: "GNU General Public License",
                    dictFileName: "mac-Collins5.dictionary",
                    downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/mac-Collins5.dictionary.zip")!)
                    .listItemTint(ListItemTint.monochrome)
                ListItem(
                    dictName: "简明英汉字典增强版 (zip: 198.2M) (file: 314.3M)",
                    dictLicense: "MIT License",
                    dictFileName: "简明英汉字典增强版.dictionary",
                    downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/jm-ec-enhanced-version.dictionary.zip")!)
            }
        }
    }
}

fileprivate func saveFile(from location: URL, callback: (_ savedURL: URL) -> Void) {
    // check for and handle errors:
    // * downloadTask.response should be an HTTPURLResponse with statusCode in 200..<299 ???
    do {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        // location.lastPathComponent is for a sample example: "CFNetworkDownload_4PJQBe.tmp"
        // savedURL is for a sample example: "file:///Users/gaocong/Library/Containers/com.gaozhanting.DictAssistantApp/Data/Documents/CFNetworkDownload_4PJQBe.tmp"
        let savedURL = documentsURL.appendingPathComponent(location.lastPathComponent + ".zip")
        
        // remove dist before move to there; otherwise move may failed with "because an item with the same name already exists" error.
        if FileManager.default.fileExists(atPath: savedURL.path) {
            try FileManager.default.removeItem(at: savedURL)
        }
        try FileManager.default.moveItem(at: location, to: savedURL)
        
        callback(savedURL)
    } catch {
        // handle filesystem error
        logger.info("saveFile exception caught: \(error.localizedDescription)")
    }
}

// 0. prompt NSSavePanel to authorize the specified location -> yes or no
// 1. unzip to the location
fileprivate func saveDict(
    _ dictFileName: String,
    didAuthorized: @escaping (_ distURL: URL) -> Void,
    didRefused: @escaping () -> Void
) {
    do {
        let libraryURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dictionariesURL = libraryURL.appendingPathComponent("Dictionaries")
        
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            panel.isExtensionHidden = false
            panel.directoryURL = dictionariesURL
            panel.canCreateDirectories = true
            panel.nameFieldStringValue = dictFileName // "oxfordjm-ec.dictionary"
            
            guard panel.runModal() == .OK else {
                logger.info("panel runModal not return OK") // toast
                didRefused()
                return
            }
            
            guard let distURL = panel.url else {
                logger.info("panel.url is nil") // toast
                didRefused()
                return
            }
            
            didAuthorized(distURL)
        }
        
    } catch {
        logger.info("saveDict exception caught: \(error.localizedDescription)")
    }
}

/*
 func unzip(from savedURL: URL, to distURL: URL) {
 guard let data = NSData.init(contentsOf: savedURL) else {
 // toast
 return
 }
 
 do {
 let uncompressedData = try data.decompressed(using: .zlib)
 try (uncompressedData as Data).write(to: distURL, options: [.withoutOverwriting]) // failed
 } catch {
 print(error.localizedDescription) // The operation couldn’t be completed. (Cocoa error 5377.)
 }
 }
 */

// 1. command line unzip
// 2. delete zip
// 3. moveItem
fileprivate func unzipUsingCommandLine(from savedURL: URL, to distURL: URL, withAuxiliary dictFileName: String, withTest test: Bool) {
    do {
        let task = Process()
        task.launchPath = "/usr/bin/unzip"
        //        task.arguments = [savedURL.path, "-d", distURL.path]
        
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let upperURL = documentsURL.appendingPathComponent("upper", isDirectory: true) // has two folder: __MACOSX & dictFileName
        
        task.arguments = [savedURL.path, "-d", upperURL.path]
        task.launch()
        task.waitUntilExit()
        
        if !test {
            deleteSavedURL(savedURL)
        }
        
        let status = task.terminationStatus
        if status != 0 {
            logger.info("unzip task failed.")
            return
        }
        
        let dictURL = upperURL.appendingPathComponent(dictFileName)
        
        // remove dist before move to there; otherwise move may failed with "because an item with the same name already exists" error.
        if FileManager.default.fileExists(atPath: distURL.path) {
            try FileManager.default.removeItem(at: distURL)
        }
        try FileManager.default.moveItem(at: dictURL, to: distURL)
        try FileManager.default.removeItem(at: upperURL)
        
    } catch {
        logger.info("unzipUsingCommandLine exception caught: \(error.localizedDescription)")
    }
}

fileprivate func deleteSavedURL(_ savedURL: URL) {
    do {
        try FileManager.default.removeItem(at: savedURL)
    } catch {
        logger.info("deleteSavedUL exception caught: \(error.localizedDescription)")
    }
}

fileprivate func install(from location: URL, to dictFileName: String) {
    saveFile(from: location) { savedURL in
        saveDict(dictFileName,
            didAuthorized: { distURL in
                unzipUsingCommandLine(from: savedURL, to: distURL, withAuxiliary: dictFileName, withTest: false)
            },
            didRefused: {
                deleteSavedURL(savedURL)
            }
        )
    }
}

fileprivate func testInstall(dictFileName: String) {
    do {
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let savedURL = documentsURL.appendingPathComponent("CFNetworkDownload_4QD55t.tmp.zip")
        let testDistURL = documentsURL.appendingPathComponent(dictFileName, isDirectory: true)
        
        unzipUsingCommandLine(from: savedURL, to: testDistURL, withAuxiliary: dictFileName, withTest: true)
    } catch {
        logger.info("testInstall exception caught: \(error.localizedDescription)")
    }
}
    
struct ListItem: View {
    func receiveProgressUpdateCallback(calculatedProgress: Float) {
        progressValue = calculatedProgress
    }
    
    func finishedDownloadingCallback(location: URL) {
        isDownloading = false
        install(from: location, to: dictFileName)
    }
    
    let dictName: String
    let dictLicense: String
    let dictFileName: String
    let downloadURL: URL
    
    @State var progressValue: Float = 0.0
    @State var isDownloading: Bool = false
    
    @State private var test: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dictName).font(.headline)
                Text(dictLicense)
                    .preferenceDescription()
            }
            
            Spacer()
            
            if isDownloading {
                ProgressView(value: progressValue)
                    .frame(maxWidth: 100)
                    .frame(minWidth: 40)
            }
            
            if test {
                Button("test", action: {
                    testInstall(dictFileName: dictFileName)
                })
            } else {
                Button(action: {
                    isDownloading = true
                    progressValue = 0.0
                    let downloadDelegate = DownloadDelegate.init(
                        receiveProgressUpdateCallback: receiveProgressUpdateCallback,
                        finishedDownloadingCallback: finishedDownloadingCallback
                    )
                    let urlSession = URLSession(
                        configuration: .default,
                        delegate: downloadDelegate,
                        delegateQueue: nil
                    )
                    let downloadTask = urlSession.downloadTask(with: downloadURL)
                    downloadTask.resume()
                }, label: {
                    Image(systemName: "square.and.arrow.down")
                })
                .disabled(isDownloading)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    // URLSessionDownloadDelegate
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        finishedDownloadingCallback(location)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        receiveProgressUpdateCallback(calculatedProgress)
    }
    
    // URLSessionTaskDelegate
    // * client error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // toast(error)
        // stop
    }
    
    let receiveProgressUpdateCallback: (Float) -> Void
    let finishedDownloadingCallback: (URL) -> Void
    
    init(receiveProgressUpdateCallback: @escaping (Float) -> Void, finishedDownloadingCallback: @escaping (URL) -> Void) {
        self.receiveProgressUpdateCallback = receiveProgressUpdateCallback
        self.finishedDownloadingCallback = finishedDownloadingCallback
    }
}

struct DictsView_Previews: PreviewProvider {
    static var previews: some View {
        DictionariesView()
            .frame(width: 650, height: 500)
    }
}
