//
//  DictInstallView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/5.
//

import SwiftUI

struct Dict {
    let name: String
    let sourceURL: URL?
    let license: String
    let licenseURL: URL?
    let installedName: String
    let downloadURL: URL?
}

let dicts: [String: Dict] = [
    "Concise Oxford English Dictionary 11th.dictionary.zip":
        Dict(name: "Concise Oxford English Dictionary 11th", //(size: 41.3M)(wordCount: 78,752)
             sourceURL: URL(string: "https://mdx.mdict.org/%E5%85%AD%E5%A4%A7%E7%9F%A5%E5%90%8D%E8%AF%8D%E5%85%B8/%E7%89%9B%E6%B4%A5_Oxford/Concise%20Oxford%20English%20Dictionary%2011th_%2014-4-15/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Concise Oxford English Dictionary 11th.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Concise%20Oxford%20English%20Dictionary%2011th.dictionary.zip")!
            ),
    
    "Babylon_English.dictionary.zip":
        Dict(name: "Babylon_English.dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English.dictionary.zip")!
            ),
    
    "简明英汉字典增强版.dictionary.zip":
        Dict(name: "简明英汉字典增强版", //(size: 314.3M)(wordCount: 3,240,000)
             sourceURL: URL(string: "https://github.com/skywind3000/ECDICT")!,
             license: "MIT License",
             licenseURL: URL(string: "https://mit-license.org/")!,
             installedName: "简明英汉字典增强版.dictionary",
             downloadURL: URL(string: "https://github.com/skywind3000/ECDICT")!
            ),
    
    "lazyworm-ec.dictionary.zip":
        Dict(name: "懒虫简明英汉词典",
             sourceURL: URL(string: "http://download.huzheng.org/zh_CN/")!,
             license: "?",
             licenseURL: nil,
             installedName: "lazyworm-ec.dictionary",
             downloadURL: nil
            ),
    
    "mac-yinghancidian.dictionary.zip":
        Dict(name: "英漢字典CDic",
             sourceURL: URL(string: "http://download.huzheng.org/zh_TW/")!,
             license: "?",
             licenseURL: URL(string: "http://cview.com.tw/")!,
             installedName: "mac-yinghancidian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/mac-yinghancidian.dictionary.zip")!
            ),
    
    "lazyworm-ec-big5.dictionary.zip":
        Dict(name: "懶蟲簡明英漢詞典",
             sourceURL: URL(string: "http://download.huzheng.org/zh_TW/")!,
             license: "?",
             licenseURL: nil,
             installedName: "lazyworm-ec-big5.dictionary",
             downloadURL: nil
            ),
    
    "mac-jmdict-en-ja.dictionary.zip":
        Dict(name: "JMDict English-Japanese dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/ja/")!,
             license: "The EDRDG Licence",
             licenseURL: URL(string: "https://www.edrdg.org/edrdg/newlic.html")!,
             installedName: "mac-jmdict-en-ja.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/mac-jmdict-en-ja.dictionary.zip")!
            ),
    
    "Babylon_English_Japanese.dictionary.zip":
        Dict(name: "Babylon English-Japanese",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Japanese.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Japanese.dictionary.zip")!
            ),
    
    "gene.dictionary.zip":
        Dict(name: "gene",
             sourceURL: URL(string: "https://github.com/amanokenzi/dictionary-en-jp")!,
             license: "?",
             licenseURL: nil,
             installedName: "gene.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/gene.dictionary.zip")
            ),
    
    "Babylon_English_Korean.dictionary.zip":
        Dict(name: "Babylon English-Korean dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Korean.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Korean.dictionary.zip")!
            ),
    
    "Babylon_English_German.dictionary.zip":
        Dict(name: "Babylon English-German dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_German.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_German.dictionary.zip")!
            ),
    
    "Babylon_English_French.dictionary.zip":
        Dict(name: "Babylon English-French dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_French.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_French.dictionary.zip")!
            ),
    
    "Babylon_English_Spanish.dictionary.zip":
        Dict(name: "Babylon English-Spanish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Spanish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Spanish.dictionary.zip")!
            ),
    
    "Babylon_English_Portuguese.dictionary.zip":
        Dict(name: "Babylon English-Portuguese dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Portuguese.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Portuguese.dictionary.zip")!
            ),
    
    "Babylon_English_Italian.dictionary.zip":
        Dict(name: "Babylon English-Italian dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Italian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Italian.dictionary.zip")!
            ),
    
    "Babylon_English_Dutch.dictionary.zip":
        Dict(name: "Babylon English-Dutch dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Dutch.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Dutch.dictionary.zip")!
            ),
    
    "Babylon_English_Swedish.dictionary.zip":
        Dict(name: "Babylon English-Swedish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Swedish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Swedish.dictionary.zip")!
            ),
    
    "Babylon_English_Russian.dictionary.zip":
        Dict(name: "Babylon English-Russian dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Russian.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Russian.dictionary.zip")!
            ),
    
    "Babylon_English_Greek.dictionary.zip":
        Dict(name: "Babylon English-Greek dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Greek.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Greek.dictionary.zip")!
            ),
    
    "Babylon_English_Turkish.dictionary.zip":
        Dict(name: "Babylon English-Turkish dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Turkish.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Turkish.dictionary.zip")!
            ),
    
    "Babylon_English_Hebrew.dictionary.zip":
        Dict(name: "Babylon English-Hebrew dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/babylon/bidirectional/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Hebrew.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Hebrew.dictionary.zip")!
            ),
    
    "Babylon_English_Arabic.dictionary.zip":
        Dict(name: "Babylon English-Arabic dictionary",
             sourceURL: URL(string: "https://mdx.mdict.org/%E6%8C%89%E8%AF%8D%E5%85%B8%E8%AF%AD%E7%A7%8D%E6%9D%A5%E5%88%86%E7%B1%BB/%E9%98%BF%E6%8B%89%E4%BC%AF%E8%AF%AD/")!,
             license: "?",
             licenseURL: nil,
             installedName: "Babylon_English_Arabic.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/Babylon_English_Arabic.dictionary.zip")!
            ),
    
    "shabdanjali.dictionary.zip":
        Dict(name: "English-Hindi Shabdanjali Dictionary",
             sourceURL: URL(string: "http://download.huzheng.org/misc/")!,
             license: "?",
             licenseURL: nil,
             installedName: "shabdanjali.dictionary",
             downloadURL: URL(string: "https://github.com/gaozhanting/AppleSmallSizeDicts/raw/main/shabdanjali.dictionary.zip")!
            )
]

// 0. prompt NSSavePanel to authorize the specified location -> yes or no
// 1. unzip to the location
private func saveDict(_ dictInstalledName: String, didAuthorized: @escaping (_ distURL: URL) -> Void) {
    do {
        let libraryURL = try FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dictionariesURL = libraryURL.appendingPathComponent("Dictionaries")
        
        DispatchQueue.main.async {
            let panel = NSSavePanel()
            let prefixMessage = NSLocalizedString("The installed path should be", comment: "")
            panel.message = "\(prefixMessage): /Users/\(NSUserName())/Library/Dictionaries"
            panel.showsTagField = false
            panel.directoryURL = dictionariesURL
            panel.nameFieldStringValue = dictInstalledName // "oxfordjm-ec.dictionary"
            
            panel.canCreateDirectories = true
            panel.canSelectHiddenExtension = false
            panel.isExtensionHidden = false
            
            guard panel.runModal() == .OK else {
                logger.info("panel runModal not return OK, refused.") // toast
                return
            }
            
            guard let distURL = panel.url else {
                logger.info("panel.url is nil") // toast
                return
            }
            
            didAuthorized(distURL)
        }
        
    } catch {
        logger.error("saveDict exception caught: \(error.localizedDescription)")
    }
}

// 1. command line unzip
// 2. delete zip
// 3. moveItem
private func unzipUsingCommandLine(from dictFile: URL, to distURL: URL, withAuxiliary dictInstalledName: String) {
    do {
        let task = Process()
        task.launchPath = "/usr/bin/unzip"
        //        task.arguments = [savedURL.path, "-d", distURL.path]
        
        let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let upperURL = documentsURL.appendingPathComponent("upper", isDirectory: true) // has two folder: __MACOSX & dictFileName
        
        task.arguments = [dictFile.path, "-d", upperURL.path]
        task.launch()
        task.waitUntilExit()
        
        let status = task.terminationStatus
        if status != 0 {
            logger.error("unzip task failed.")
            return
        }
        
        let dictURL = upperURL.appendingPathComponent(dictInstalledName)
        
        // remove dist before move to there; otherwise move may failed with "because an item with the same name already exists" error.
        // this means replace, otherwise although prompt replace from NSSavePanel, it will still failed blamed to FileManager.default.moveItem API.
        if FileManager.default.fileExists(atPath: distURL.path) {
            try FileManager.default.removeItem(at: distURL)
        }
        try FileManager.default.moveItem(at: dictURL, to: distURL)
        try FileManager.default.removeItem(at: upperURL)
        
    } catch {
        logger.error("unzipUsingCommandLine exception caught: \(error.localizedDescription)")
    }
}

func searchResourceDictZipFiles() -> [String] {
    guard let resourcePath = Bundle.main.resourcePath else {
        logger.error("Could't find bundle main resource path.")
        return []
    }
    
    let dirEnum = FileManager.default.enumerator(atPath: resourcePath)
    var results: [String] = []
    while let file = dirEnum?.nextObject() as? String {
        if file.hasSuffix(".zip") {
            logger.info(">>found file: \(file)")
            results.append(file)
        }
    }
    return results
}

func targetDicts() -> [Dict] {
    let files = searchResourceDictZipFiles()
    return files.map { dicts[$0]! }
}

private func install(_ dictInstalledName: String) {
    guard let dictFile = Bundle.main.url(forResource: "\(dictInstalledName).zip", withExtension: nil) else {
        logger.error("Couldn't find \(dictInstalledName, privacy: .public).zip in main bundle.")
        return
    }
    
    saveDict(dictInstalledName) { distURL in
        unzipUsingCommandLine(from: dictFile, to: distURL, withAuxiliary: dictInstalledName)
    }
}

struct DictInstallView: View {
    let dicts: [Dict]
    
    var body: some View {
        VStack {
            ForEach(dicts, id: \.name) { dict in
                DictItemInstallView(dict: dict)
            }
        }
        .padding()
        .frame(width: 450)
    }
}

private struct DictItemInstallView: View {
    @Environment(\.openURL) var openURL
    
    let dict: Dict
    
    func installDict() {
        install(dict.installedName)
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text(dict.name)
            
            if let sourceURL = dict.sourceURL, let downloadURL = dict.downloadURL {
                MiniInfoView {
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
                Spacer()
            } else if let sourceURL = dict.sourceURL {
                MiniInfoView {
                    VStack(alignment: .trailing) {
                        HStack {
                            Text("sourceURL:")
                            Button(action: { openURL(sourceURL) }, label: {
                                Image(systemName: "arrow.right.circle")
                                    .font(.footnote)
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                Spacer()
            } else {
                Spacer()
            }
            
            Button("Install") {
                installDict()
            }
        }
    }
}

struct DictInstallView_Previews: PreviewProvider {
    static var previews: some View {
        DictInstallView(dicts: targetDicts())
    }
}
