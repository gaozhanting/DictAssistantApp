//
//  DictionariesView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/14.
//

import SwiftUI

struct DictionariesView: View {
    @State private var isShowingPopover = false
    
    var body: some View {
        DictsView()
            .overlay(
                Button(action: { isShowingPopover = true }, label: {
                    Image(systemName: "questionmark").font(.body)
                })
                .clipShape(Circle())
                .padding()
                .shadow(radius: 1)
                .popover(isPresented: $isShowingPopover, arrowEdge: .leading, content: {
                    InfoView()
                })
                ,
                alignment: .bottomTrailing
            )
    }
}

fileprivate struct DictsView: View {
    
    struct Dict {
        let name: String
        let sourceURL: URL?
        let license: String
        let licenseURL: URL?
        let installedName: String
        let downloadURL: URL?
    }
    
    private let dicts: [Dict] = [
        Dict(name: "Concise Oxford English Dictionary 11th", //(size: 41.3M)(wordCount: 78,752)
             sourceURL: URL(string: "https://mdx.mdict.org/%E5%85%AD%E5%A4%A7%E7%9F%A5%E5%90%8D%E8%AF%8D%E5%85%B8/%E7%89%9B%E6%B4%A5_Oxford/Concise%20Oxford%20English%20Dictionary%2011th_%2014-4-15/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Concise Oxford English Dictionary 11th.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Concise%20Oxford%20English%20Dictionary%2011th.dictionary.zip")!
        ),
        Dict(name: "Babylon_English.dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English.dictionary.zip")!
        ),
                
        Dict(name: "简明英汉字典增强版", //(size: 314.3M)(wordCount: 3,240,000)
             sourceURL: URL(string: "https://github.com/skywind3000/ECDICT")!,
             license: "MIT License",
             licenseURL: URL(string: "https://mit-license.org/")!,
             installedName: "简明英汉字典增强版.dictionary",
             downloadURL: nil
        ),
        Dict(name: "懒虫简明英汉词典",
             sourceURL: URL(string: "http://download.huzheng.org/zh_CN/")!,
             license: "?",
             licenseURL: nil,
             installedName: "lazyworm-ec.dictionary",
             downloadURL: nil
        ),
        
        Dict(name: "英漢字典CDic",
             sourceURL: URL(string: "http://download.huzheng.org/zh_TW/")!,
             license: "?",
             licenseURL: URL(string: "http://cview.com.tw/")!,
             installedName: "mac-yinghancidian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/mac-yinghancidian.dictionary.zip")!
        ),
        Dict(name: "懶蟲簡明英漢詞典",
             sourceURL: URL(string: "http://download.huzheng.org/zh_TW/")!,
             license: "?",
             licenseURL: nil,
             installedName: "lazyworm-ec-big5.dictionary",
             downloadURL: nil
        ),
        
        Dict(name: "JMDict English-Japanese dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/ja/")!,
             license: "The EDRDG Licence",
             licenseURL: URL(string: "https://www.edrdg.org/edrdg/newlic.html")!,
             installedName: "mac-jmdict-en-ja.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/mac-jmdict-en-ja.dictionary.zip")!
        ),
        Dict(name: "Babylon English-Japanese",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Japanese.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Japanese.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Korean dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Korean.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Korean.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-German dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_German.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_German.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-French dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_French.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_French.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Spanish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Spanish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Spanish.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Portuguese dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Portuguese.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Portuguese.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Italian dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Italian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Italian.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Dutch dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Dutch.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Dutch.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Swedish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Swedish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Swedish.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Russian dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Russian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Russian.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Greek dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Greek.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Greek.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Turkish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Turkish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Turkish.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Hebrew dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Hebrew.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Hebrew.dictionary.zip")!
        ),
        
        Dict(name: "Babylon English-Arabic dictionary",
             sourceURL: URL(string: "https://mdx.mdict.org/%E6%8C%89%E8%AF%8D%E5%85%B8%E8%AF%AD%E7%A7%8D%E6%9D%A5%E5%88%86%E7%B1%BB/%E9%98%BF%E6%8B%89%E4%BC%AF%E8%AF%AD/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Arabic.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Arabic.dictionary.zip")!
        ),
        
        Dict(name: "English-Hindi Shabdanjali Dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/misc/")!,
             license: "?",
             licenseURL: nil,
             installedName: "shabdanjali.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/shabdanjali.dictionary.zip")!
        )
    ]
    
    var body: some View {
        ForEach(dicts, id:\.self.name) { d in
            DictItemView(
                name: d.name,
                sourceURL: d.sourceURL,
                license: d.license,
                licenseURL: d.licenseURL,
                installedName: d.installedName,
                downloadURL: d.downloadURL
            )
        }
        .padding()
    }
}

fileprivate struct InfoView: View {
    var body: some View {
        Text("These dictionaries files are some free concise dictionaries I searched from the internet and converted to Apple dictionary format files for you, using an open source tool called pyglossary. These dictionaries, as a complement and third party dictionaries of the system built in dictionary of Apple Dictionary.app, is suitable for this APP because these are concise and free. Notice it may have different translation text style, and you could select and deselect some content display options to get a better view.\n\nOf course, you can use built-in dictionary, or other third party dictionaries for Apple Dictionary.app. The database of this APP is come from these file through Apple Dictionary.app. It is local and offline.\n\nYou just need to click the download button, and when the downloading is completed, a save panel will prompt, because it need your permission to save the downloaded file at the specific built-in Apple Dictionary.app dictionaries folder, you need to use the default path provided. When all have done, you could open the Dictionary.app preferences to select and re-order them; my recommendation is to order the concise dictionary first, then more detailed dictionary after, anyhow, you are free as your wish.")
            .padding()
            .frame(width: 520, height: 340)
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
    
struct DictItemView: View {
    func receiveProgressUpdateCallback(calculatedProgress: Float) {
        progressValue = calculatedProgress
    }
    
    func finishedDownloadingCallback(location: URL) {
        isDownloading = false
        install(from: location, to: installedName)
    }
    
    let name: String
    let sourceURL: URL?
    let license: String
    let licenseURL: URL?
    let installedName: String
    let downloadURL: URL?
    
    @State var progressValue: Float = 0.0
    @State var isDownloading: Bool = false
    
    @State private var test: Bool = false
    
    @Environment(\.openURL) var openURL

    @State private var isShowingPopoverOfEC = false
    @State private var isShowingPopover = false
    
    var body: some View {
        HStack(alignment: .top) {
            if test {
                Button("test", action: {
                    testInstall(dictFileName: installedName)
                })
            } else {
                if let downloadURL = downloadURL {
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
                } else {
                    Button(action: {}, label: {
                        Image(systemName: "square.and.arrow.down")
                    })
                    .disabled(true)
                }
            }
            
            HStack {
                Text(name)
                
                if name == "简明英汉字典增强版" {
                    Button(action: { isShowingPopoverOfEC = true }, label: {
                        Image(systemName: "info.circle.fill")
                            .font(.footnote)
                    })
                    .buttonStyle(PlainButtonStyle())
                    
                    .popover(isPresented: $isShowingPopoverOfEC, content: {
                        Text("Notice you can deselect `英文释义` option in Dictionary.app preferences, to get more concise translation.")
                            .font(.callout)
                            .padding()
                    })
                }
                
                if let sourceURL = sourceURL, let downloadURL = downloadURL {
                    Button(action: { isShowingPopover = true }, label: {
                        Image(systemName: "info.circle")
                            .font(.footnote)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .popover(isPresented: $isShowingPopover) {
                        VStack(alignment: .trailing) {
                            HStack {
                                Text("sourceURL:")
                                Button(action: { openURL(sourceURL) }, label: {
                                    Image(systemName: "arrow.right.circle")
                                        .font(.footnote)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                            HStack {
                                Text("downloadURL:")
                                Button(action: { openURL(downloadURL) }, label: {
                                    Image(systemName: "arrow.right.circle")
                                        .font(.footnote)
                                })
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                } else {
                    Spacer()
                }
            }
            .font(.headline)
            
            Spacer()
            
            if isDownloading {
                ProgressView(value: progressValue)
                    .frame(maxWidth: 100)
                    .frame(minWidth: 40)
            }
            
        }
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
        Group {
            DictionariesView()
                .frame(width: 650, height: 500)
            
            InfoView()
        }
    }
}
