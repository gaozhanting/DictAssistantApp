//
//  GerEntriesPersistence.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/28.
//

import Foundation
import Cocoa
import CoreData
import DataBases

func getAllGerEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<GerEntry> = GerEntry.fetchRequest()

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

func batchResetGerEntries() {
    batchDeleteAllGerEntries {
        let gerEntriesDB = Vocabularies.readToArray(from: "Babylon_English_German.csv")
        let entries: [(String, String)] = gerEntriesDB.map { line in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchInsertGerEntries(entries: entries)
    }
}

private func batchDeleteAllGerEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GerEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all ger enties: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

private func batchInsertGerEntries(entries: [(String, String)]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: GerEntry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch inert ger entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
