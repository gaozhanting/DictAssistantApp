//
//  GreEntriesPersistence.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/28.
//

import Foundation
import Cocoa
import CoreData
import DataBases

func getAllGreEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<GreEntry> = GreEntry.fetchRequest()

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

func batchResetGreEntries() {
    batchDeleteAllGreEntries {
        let greEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Greek.csv")
        let entries: [(String, String)] = greEntriesDB.enumerated().map { (index, line) in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchInsertGreEntries(entries: entries)
    }
}

private func batchDeleteAllGreEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = GreEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all gre enties: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

private func batchInsertGreEntries(entries: [(String, String)]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: GreEntry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch inert gre entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
