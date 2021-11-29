//
//  SpaEntriesPersistence.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/28.
//

import Foundation
import Cocoa
import CoreData
import DataBases

func getAllSpaEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<SpaEntry> = SpaEntry.fetchRequest()

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

func batchResetSpaEntries() {
    batchDeleteAllSpaEntries {
        let spaEntriesDB = Vocabularies.readToArray(from: "Babylon_English_Spanish.csv")
        let entries: [(String, String)] = spaEntriesDB.map { line in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchInsertSpaEntries(entries: entries)
    }
}

private func batchDeleteAllSpaEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = SpaEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all spa enties: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

private func batchInsertSpaEntries(entries: [(String, String)]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: SpaEntry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch inert spa entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
