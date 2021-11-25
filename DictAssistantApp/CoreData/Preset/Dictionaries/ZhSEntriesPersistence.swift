//
//  ZhS.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/25.
//

import Foundation
import Cocoa
import CoreData

func getAllZhSEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<ZhSEntry> = ZhSEntry.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let tuplesSeq = results.map {
            ($0.word!, $0.trans!)
        }
        let dict = Dictionary.init(uniqueKeysWithValues: tuplesSeq)
        return dict
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Dictionary()
    }
}

//func batchInsertZhSEntries() {
//    batchDeleteAllZhSEntries {
//        let entries: [(String, String)] = defaultEntriesDB.map { line in
//            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
//            return (String(wordTrans[0]), String(wordTrans[1]))
//        }
//        batchInsertZhSEntries(entries: entries)
//    }
//}
//
//func batchDeleteAllZhSEntries() {
//
//}
//
//func batchInsertZhSEntries() {
//
//}
