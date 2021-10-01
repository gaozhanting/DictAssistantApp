//
//  CustomDictPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

// for cache for running query (now you have a quick custom dict)
var customDictDict: Dictionary<String, String> = getAllCustomDict()

private func getAllCustomDict() -> Dictionary<String, String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
    
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
        return Dictionary()
    }
}

// for directly query (slow, which is similar of system dict service)
func getEntry(of word: String) -> CustomDict? {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
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
        return nil
    }
}

func batchUpsertCustomDicts(entries: [Entry], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    // this got upsert behavior when do batch insert
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    
    let insertRequest = NSBatchInsertRequest(
        entity: CustomDict.entity(),
        objects: entries.map { entry in
            ["word": entry.word, "trans": entry.trans]
        }
    )
    
    do {
        try context.execute(insertRequest)
        customDictDict = getAllCustomDict()
        cachedDict = [:]
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch upsert custom dicts: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func removeMultiCustomDict(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext

    for word in words {
        let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
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
        customDictDict = getAllCustomDict()
        cachedDict = [:]
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func upsertCustomDict(entry: Entry) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", entry.word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first { // update
            result.word = entry.word
            result.trans = entry.trans
        } else { // insert
            let newCustomDict = CustomDict(context: context)
            newCustomDict.word = entry.word
            newCustomDict.trans = entry.trans
        }
    } catch {
        logger.error("Failed to upsert custom dict: \(error.localizedDescription)")
    }
    saveContext(didSucceed: {
        customDictDict = getAllCustomDict()
        cachedDict = [:]
        trCallBack()
    })
}

func removeCustomDict(word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            context.delete(result)
        }
    } catch {
        logger.error("Failed to remove custom dict: \(error.localizedDescription)")
    }
    saveContext(didSucceed: {
        customDictDict = getAllCustomDict()
        cachedDict = [:]
        trCallBack()
    })
}
