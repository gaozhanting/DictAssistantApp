//
//  EntriesPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

// for cache for running query (now you have a quick custom dict)
var entriesDict: Dictionary<String, String> = getAllEntries()

private func getAllEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let tuplesSeq = results.map {
            ($0.word!, $0.trans!)
        }
        let dict = Dictionary.init(uniqueKeysWithValues: tuplesSeq)
//        let dict = Dictionary.init(tuplesSeq, uniquingKeysWith: { (_, last) in last })
        return dict
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Dictionary()
    }
}

// for directly query (slow, which is similar of system dict service)
func getEntry(of word: String) -> Entry? {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
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

func batchUpsertEntries(entries: [(String, String)], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    // this got upsert behavior when do batch insert
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    let insertRequest = NSBatchInsertRequest(
        entity: Entry.entity(),
        objects: entries.map { (word, trans) in
            ["word": word, "trans": trans]
        }
    )
    insertRequest.resultType = .objectIDs
    
    do {
        let result = try context.execute(insertRequest) as? NSBatchInsertResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSInsertedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        entriesDict = getAllEntries()
        cachedDict = [:]
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch upsert entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func batchDeleteAllEntries(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Entry.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        entriesDict = getAllEntries()
        cachedDict = [:]
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all entries: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func removeMultiEntries(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext

    for word in words {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let result = results.first {
                context.delete(result)
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
        }
    }
    saveContext(didSucceed: {
        entriesDict = getAllEntries()
        cachedDict = [:]
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func upsertEntry(word: String, trans: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first { // update
            result.word = word
            result.trans = trans
        } else { // insert
            let newEntry = Entry(context: context)
            newEntry.word = word
            newEntry.trans = trans
        }
    } catch {
        logger.error("Failed to upsert custom dict: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        entriesDict = getAllEntries()
        cachedDict = [:]
        trCallBack()
    })
}

func removeEntry(word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            context.delete(result)
        }
    } catch {
        logger.error("Failed to remove entry: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        entriesDict = getAllEntries()
        cachedDict = [:]
        trCallBack()
    })
}
