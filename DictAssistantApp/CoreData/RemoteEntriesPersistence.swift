//
//  RemoteEntriesPersistence.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/29.
//

import Foundation
import Cocoa
import CoreData

func getAllRemoteEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<RemoteEntry> = RemoteEntry.fetchRequest()

    do {
        let results = try context.fetch(fetchRequest)
        let tuplesSeq = results.map {
            ($0.word!, "\($0.word!) \($0.trans!)") // DictionaryServices trans include the title word, simulate Apple Dictionary behavior
        }
        let dict = Dictionary.init(uniqueKeysWithValues: tuplesSeq)
        return dict
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Dictionary()
    }
}

func getRemoteEntry(of word: String) -> RemoteEntry? {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<RemoteEntry> = RemoteEntry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            return result
        } else {
            return nil
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return nil
    }
}

func batchResetRemoteEntries(
    from urlString: String,
    didSucceed: @escaping () -> Void = {},
    didFailed: @escaping () -> Void = {}
) {
    logger.info("]] batchResetRemoteEntries begin!")
    
    guard let url = URL(string: urlString) else {
        NSApplication.shared.presentError(NSError(domain: "", code: NSURLErrorBadURL))
        didFailed()
        return
    }
    
    DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
        do {
            // only place to access network, in the App
            let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
            logger.info("]] contents done!") // 4s (download)
            
            let lines = contents.components(separatedBy: .newlines)
            logger.info("]] lines done!") // 1s
            
            var entries: [(String, String)] = []
            for (index, line) in lines.enumerated() {
                let wordTrans = line.split(separator: Character(","), maxSplits: 1)
                if wordTrans.count == 2 {
                    let word = String(wordTrans[0])
                    let trans = String(wordTrans[1])
                    entries.append((word, trans))
                } else {
                    logger.info("\(urlString) has invalid format with line number: \(index)")
                }
            }
            logger.info("]] entries done!") // 3s
            
            batchDeleteAllRemoteEntries(
                didSucceed: {
                    logger.info("]] batchDeleteAllRemoteEntries done!") // 1s
                    batchInsertRemoteEntries(
                        entries: entries,
                        didSucceed: {
                            logger.info("]] batchInsertRemoteEntries done!") // 4s
                            didSucceed()
                        },
                        didFailed: { didFailed() }
                    )
                },
                didFailed: { didFailed() }
            )
        } catch {
            DispatchQueue.main.async {
                NSApplication.shared.presentError(error as NSError)
                didFailed()
            }
            return
        }
    }
}

private func batchDeleteAllRemoteEntries(
    didSucceed: @escaping () -> Void = {},
    didFailed: @escaping () -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RemoteEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        DispatchQueue.main.async {
            logger.error("Failed to batch delete all remote enties: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
            didFailed()
        }
    }
}

private func batchInsertRemoteEntries(
    entries: [(String, String)],
    didSucceed: @escaping () -> Void = {},
    didFailed: @escaping () -> Void = {}
) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: RemoteEntry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs

    do {
        try context.execute(insertRequest)
        didSucceed()
    } catch {
        DispatchQueue.main.async {
            logger.error("Failed to batch insert remote entries: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
            didFailed()
        }
    }
}
