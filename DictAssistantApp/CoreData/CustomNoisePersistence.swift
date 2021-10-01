//
//  CustomNoise.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Foundation
import Cocoa
import CoreData

// for cache for running query
var allCustomNoisesSet: Set<String> = getAllCustomNoiseSet()

private func getAllCustomNoiseSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomNoise> = CustomNoise.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return Set.init(
            results.map { $0.word! }
        )
    } catch {
        logger.error("Failed to fetch all custom noises: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchInsertCustomNoise(_ words: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: CustomNoise.entity(),
        objects: words.map { word in
            ["word": word]
        }
    )
    
    do {
        try context.execute(insertRequest)
        allCustomNoisesSet = getAllCustomNoiseSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert custom noise:\(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func batchDeleteAllCustomNoise() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CustomNoise.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
    } catch {
        logger.error("Failed to batch delete all custom noise: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    allCustomNoisesSet = getAllCustomNoiseSet()
    trCallBack()
}

func removeMultiCustomNoise(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    for word in words {
        let fetchRequest: NSFetchRequest<CustomNoise> = CustomNoise.fetchRequest()
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
        allCustomNoisesSet = getAllCustomNoiseSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func addCustomNoise(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomNoise> = CustomNoise.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let newCustomNoise = CustomNoise(context: context)
            newCustomNoise.word = word
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        allCustomNoisesSet = getAllCustomNoiseSet()
        trCallBack()
    })
}

func removeCustomNoise(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomNoise> = CustomNoise.fetchRequest()
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
        allCustomNoisesSet = getAllCustomNoiseSet()
        trCallBack()
    })
}
