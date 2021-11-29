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

// only place to access network, in the App
func makeRemoteEntriesDB(from urlString: String) -> [String]? {
    guard let url = URL(string: urlString) else {
        return nil
    }
    
    do {
        let contents = try String(contentsOf: url, encoding: String.Encoding.utf8)
        let lines = contents.components(separatedBy: .newlines)
        return lines
    } catch {
        NSApplication.shared.presentError(error as NSError)
        return nil
    }
}

func batchResetRemoteEntries(from urlString: String, didSucceed: @escaping () -> Void = {}) {
    batchDeleteAllRemoteEntries {
        guard let remoteEntriesDB = makeRemoteEntriesDB(from: urlString) else {
            return
        }
        
        var entries: [(String, String)] = []
        for (index, line) in remoteEntriesDB.enumerated() {
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            if wordTrans.count == 2 {
                let word = String(wordTrans[0])
                let trans = String(wordTrans[1])
                entries.append((word, trans))
            } else {
                logger.info("\(urlString) has invalid format with line number: \(index)")
            }
        }
        batchInsertRemoteEntries(entries: entries) {
            didSucceed()
        }
    }
}

private func batchDeleteAllRemoteEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = RemoteEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all remote enties: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

private func batchInsertRemoteEntries(entries: [(String, String)], didSucceed: @escaping () -> Void = {}) {
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
        logger.error("Failed to batch inert remote entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
