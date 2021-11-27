//
//  ZhS.swift
//  DictAssistantApp Zh_S
//
//  Created by Gao Cong on 2021/11/25.
//

import Foundation
import Cocoa
import CoreData

//@objc(WhichEntry)
//public class WhichEntry: NSManagedObject {
//
//}
//extension WhichEntry {
//    @nonobjc public class func fetchRequest(entityName: String) -> NSFetchRequest<WhichEntry> {
//        return NSFetchRequest<WhichEntry>(entityName: entityName)
//    }
//
//    @NSManaged public var trans: String?
//    @NSManaged public var word: String?
//
//}
//extension WhichEntry : Identifiable {
//
//}
//
//// getEntries(entityName: "ZhSEntry")
//// getEntries(entityName: "JapEntry")
//
//// switch currentEntries (which is current inner dict)
//func getEntries(entityName: String) -> Dictionary<String, String> {
//    let context = persistentContainer.viewContext
//
//    let fetchRequest: NSFetchRequest<WhichEntry> = WhichEntry.fetchRequest(entityName: entityName)
//
//    do {
//        let results = try context.fetch(fetchRequest)
//        let tuplesSeq = results.map {
//            ($0.word!, $0.trans!)
//        }
//        let dict = Dictionary.init(uniqueKeysWithValues: tuplesSeq)
//        return dict
//    } catch {
//        logger.error("Failed to fetch request: \(error.localizedDescription)")
//        NSApplication.shared.presentError(error as NSError)
//        return Dictionary()
//    }
//}
//
//// batchInsertWhichEntries(zhsEntriesDB)
//// batchInsertWhichEntries(japEntriesDB)
//
//// only for build fixed coredata, from csv dict file
//func batchInsertWhichEntries(entityName: String, whichEntriesDB: [String]) {
//    batchDeleteAllWhichEntries(entityName: entityName) {
//        let entries: [(String, String)] = whichEntriesDB.map { line in
//            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
//            return (String(wordTrans[0]), String(wordTrans[1]))
//        }
//        batchInsertWhichEntries(entries: entries)
//    }
//}
//
//private func batchDeleteAllWhichEntries(entityName: String, didSucceed: @escaping () -> Void = {}) {
//    let context = persistentContainer.viewContext
//
//    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WhichEntry.fetchRequest()
//    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//    deleteRequest.resultType = .resultTypeObjectIDs
//
//    do {
//        try context.execute(deleteRequest)
//        didSucceed()
//    } catch {
//        logger.error("Failed to batch delete all which enties: \(error.localizedDescription)")
//        NSApplication.shared.presentError(error as NSError)
//    }
//}
//
//private func batchInsertWhichEntries(entries: [(String, String)]) {
//    let context = persistentContainer.viewContext
//
//    let insertRequest = NSBatchInsertRequest(
//        entity: ZhSEntry.entity(),
//        objects: entries.map { (word, trans) in
//            ["word": word, "trans": trans]
//        }
//    )
//    insertRequest.resultType = .objectIDs
//
//    do {
//        try context.execute(insertRequest)
//    } catch {
//        logger.error("Failed to batch insert which entries: \(error.localizedDescription)")
//        NSApplication.shared.presentError(error as NSError)
//    }
//}

//
func getAllZhSEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<ZhSEntry> = ZhSEntry.fetchRequest()

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

func batchInsertZhSEntries() {
    batchDeleteAllZhSEntries {
        let entries: [(String, String)] = zhsEntriesDB.map { line in
            let wordTrans = line.split(separator: Character(","), maxSplits: 1)
            return (String(wordTrans[0]), String(wordTrans[1]))
        }
        batchInsertZhSEntries(entries: entries)
    }
}

private func batchDeleteAllZhSEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ZhSEntry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        try context.execute(deleteRequest)
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all ZhS enties: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

private func batchInsertZhSEntries(entries: [(String, String)]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: ZhSEntry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch inert ZhS entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
