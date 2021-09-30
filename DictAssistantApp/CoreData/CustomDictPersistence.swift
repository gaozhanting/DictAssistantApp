//
//  CustomDictPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

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

func batchUpsertCustomDicts(entries: [Entry]) {
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
    } catch {
        logger.error("Failed to batch upsert custom dicts: \(error.localizedDescription)")
    }
    refreshContentWhenChangingUseCustomDictMode()
}

func removeMultiWordsFromCustomDict(words: [String]) {
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
        }
    }
    saveContext {
        refreshContentWhenChangingUseCustomDictMode()
    }
}
