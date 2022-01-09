//
//  KnownPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

// for cache for running query
var knownSet: Set<String> = getAllKnownSet()

private func getAllKnownSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Known> = Known.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return Set.init(results.map { $0.word! })
    } catch {
        logger.error("Failed to fetch all known words: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchInsertKnown(_ words: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: Known.entity(),
        objects: words.map { word in
            ["word": word]
        }
    )
    insertRequest.resultType = .objectIDs
    
    do {
        let result = try context.execute(insertRequest) as? NSBatchInsertResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSInsertedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        knownSet = getAllKnownSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert known words:\(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func removeMultiKnown(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Known> = Known.fetchRequest()
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
        knownSet = getAllKnownSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func batchDeleteAllKnown(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Known.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])

        knownSet = getAllKnownSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all known words: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func addKnown(_ word: String,
              didSucceed: @escaping () -> Void = {},
              nothingChanged: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Known> = Known.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let newWordStatus = Known(context: context)
            newWordStatus.word = word
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        knownSet = getAllKnownSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func removeKnown(_ word: String,
                 didSucceed: @escaping () -> Void = {},
                 nothingChanged: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Known> = Known.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@ OR word = %@", word, word.lowercased())
    fetchRequest.fetchLimit = 2
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            context.delete(result)
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        knownSet = getAllKnownSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}
