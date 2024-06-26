//
//  EntriesPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

private func getAllEntries() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    
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

func getCustomEntry(of word: String) -> Entry? {
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
        
        trCallBack()
        
        let phrases = entries.map { $0.0 }.filter { $0.isPhrase }
        if !phrases.isEmpty {
            batchInsertPhrases(phrases)
        }
        
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

    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word IN %@", words)
    
    do {
        let results = try context.fetch(fetchRequest)
        for result in results {
            context.delete(result)
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    saveContext(didSucceed: {
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func upsertEntry(word: String, trans: String,
                 didSucceed: @escaping () -> Void = {},
                 nothingChanged: @escaping() -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            if result.trans! != trans { // update
                result.trans = trans
            }
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
        if word.isPhrase {
            addPhrase(word)
        }
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func removeEntry(word: String,
                 didSucceed: @escaping () -> Void = {},
                 nothingChanged: @escaping () -> Void = {}) {
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
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}
