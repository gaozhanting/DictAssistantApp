//
//  CustomPhrases.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Cocoa
import CoreData

// for cache for running query
var customPhrasesSet: Set<String> = getAllCustomPhrasesSet()

private func getAllCustomPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()

    do {
        let customePhrases = try context.fetch(fetchRequest)
        let phrases = customePhrases.map { $0.phrase! }
        return Set(phrases)
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchInsertCustomPhrases(_ phrases: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: CustomPhrase.entity(),
        objects: phrases.map { phrase in
            ["phrase": phrase]
        }
    )
    insertRequest.resultType = .objectIDs
    
    do {
        let result = try context.execute(insertRequest) as? NSBatchInsertResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSInsertedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        customPhrasesSet = getAllCustomPhrasesSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert custom phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func batchDeleteAllCustomPhrases(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CustomPhrase.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        customPhrasesSet = getAllCustomPhrasesSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all custom phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

// can't batch delete specific collection ?!
func removeMultiCustomPhrases(
    _ phrases: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    for phrase in phrases {
        let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
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
        customPhrasesSet = getAllCustomPhrasesSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func addCustomPhrase(_ phrase: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let customPhrase = CustomPhrase(context: context)
            customPhrase.phrase = phrase
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    saveContext(didSucceed: {
        customPhrasesSet = getAllCustomPhrasesSet()
    })
}
