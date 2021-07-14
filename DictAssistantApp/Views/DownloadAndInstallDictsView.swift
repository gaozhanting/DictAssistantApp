//
//  DownloadAndInstallDictsView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/14.
//

import SwiftUI

struct ListItem: View {
    func install(_ tempURL: URL) {
        do {
            let cacheURL = try FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let zipFileURL = cacheURL.appendingPathComponent("dict.zip")
            let fileURL = cacheURL.appendingPathComponent("oxfordjm-ec.dictionary", isDirectory: true)
            let userLibraryURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dictionaryURL = userLibraryURL.appendingPathComponent("Dictionaries", isDirectory: true)
            try FileManager.default.moveItem(at: tempURL, to: zipFileURL)
            
            let task = Process()
            task.launchPath = "/usr/bin/unzip" // swift API?!
            let toZipPath = cacheURL.path
            task.arguments = [zipFileURL.path, "-d", toZipPath]
            task.launch()
            task.waitUntilExit()
            let status = task.terminationStatus
            
            if status != 0 {
                print("unzip Task failed.")
                return
            }
            
            print("unzip Task succeeded.")
            DispatchQueue.main.async {
                let panel = NSSavePanel()
                panel.isExtensionHidden = false
                panel.directoryURL = dictionaryURL
                panel.canCreateDirectories = true
                panel.nameFieldStringValue = "oxfordjm-ec.dictionary"
                if panel.runModal() == .OK {
                    do {
                        let distURL = panel.url! // [Make it Default]?? MUST input: oxfordjm-ec.dictionary in /Library/Dictionaries
                        try FileManager.default.moveItem(at: fileURL, to: distURL)
                        
                        try FileManager.default.removeItem(at: zipFileURL)
                        let xxURL = cacheURL.appendingPathComponent("__MACOSX", isDirectory: true) // why?!
                        try FileManager.default.removeItem(at: xxURL)
                    }
                    catch {
                        logger.info("Failed to move file2: \(error.localizedDescription)")
                    }
                }
            }
        } catch {
            logger.info("Failed to move file: \(error.localizedDescription)")
        }
    }
    
    func receiveProgressUpdateCallback(calculatedProgress: Float) {
        progressValue = calculatedProgress
    }
    
    func finishedDownloadingCallback(location: URL) {
        install(location)
        isDownloading = false
    }
    
    var dictName: String
    var downloadURL: URL
    
    @State var progressValue: Float = 0.0
    @State var isDownloading: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(dictName).font(.headline)
                Text("GNU General Public License").font(.footnote)
            }
            
            Spacer()
            
            if isDownloading {
                ProgressView(value: progressValue)
                    .frame(maxWidth: 100)
                    .frame(minWidth: 40)
            }
            
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
}

struct DownloadAndInstallDictsView: View {
    var body: some View {
        List {
            ListItem(
                dictName: "牛津简明英汉袖珍辞典 (15.6M)",
                downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/oxfordjm-ec.dictionary.zip")!)
            ListItem(
                dictName: "牛津英汉双解美化版 (23.3M)",
                downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/mac-oxford-gb-formated.dictionary.zip")!)
            ListItem(
                dictName: "Collins Cobuild 5 (18.7M)",
                downloadURL: URL(string: "https://github.com/gaozhanting/AppleDicts/raw/main/mac-Collins5.dictionary.zip")!)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        finishedDownloadingCallback(location)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        receiveProgressUpdateCallback(calculatedProgress)
    }
    
    let receiveProgressUpdateCallback: (Float) -> Void
    let finishedDownloadingCallback: (URL) -> Void
    
    init(receiveProgressUpdateCallback: @escaping (Float) -> Void, finishedDownloadingCallback: @escaping (URL) -> Void) {
        self.receiveProgressUpdateCallback = receiveProgressUpdateCallback
        self.finishedDownloadingCallback = finishedDownloadingCallback
    }
}

struct DownloadAndInstallDictsView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadAndInstallDictsView()
    }
}
