//
//  NoisesPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import Cocoa
import CoreData
import DataBases

// for cache for running query
var noisesSet: Set<String> = getAllNoiseSet()

private func getAllNoiseSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Noise> = Noise.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return Set.init(
            results.map { $0.word! }
        )
    } catch {
        logger.error("Failed to fetch all  noises: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchResetDefaultNoises(didSucceed: @escaping () -> Void = {}) {
    batchDeleteAllNoise {
        let noisesDB = Vocabularies.readToArray(from: "noises.txt")
        batchInsertNoises(noisesDB) {
            didSucceed()
        }
    }
}

func batchInsertNoises(_ words: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: Noise.entity(),
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

        noisesSet = getAllNoiseSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert  noise:\(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func multiInsertNoises(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping () -> Void = {}
) {
    if words.count > 1000 {
        batchInsertNoises(words, didSucceed: didSucceed)
    } else {
        insertMultiNoises(words, didSucceed: didSucceed, nothingChanged: nothingChanged)
    }
}

func insertMultiNoises(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping () -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    for word in words {
        let fetchRequest: NSFetchRequest<Noise> = Noise.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newNoise = Noise(context: context)
                newNoise.word = word
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
        }
    }
    
    saveContext(didSucceed: {
        noisesSet = getAllNoiseSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func batchDeleteAllNoise(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Noise.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])

        noisesSet = getAllNoiseSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all  noise: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func removeMultiNoise(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Noise> = Noise.fetchRequest()
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
        noisesSet = getAllNoiseSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func addNoise(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Noise> = Noise.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let newNoise = Noise(context: context)
            newNoise.word = word
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        noisesSet = getAllNoiseSet()
        trCallBack()
    })
}

func removeNoise(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Noise> = Noise.fetchRequest()
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
    saveContext(didSucceed: {
        noisesSet = getAllNoiseSet()
        trCallBack()
    })
}
