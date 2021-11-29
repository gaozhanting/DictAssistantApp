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

func batchResetRemoteEntries() {
    batchDeleteAllRemoteEntries {
        let entries: [(String, String)] = remoteEntriesDB.enumerated().map { (index, line) in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchInsertRemoteEntries(entries: entries)
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

private func batchInsertRemoteEntries(entries: [(String, String)]) {
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
    } catch {
        logger.error("Failed to batch inert remote entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
