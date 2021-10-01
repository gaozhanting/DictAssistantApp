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
    
    do {
        try context.execute(insertRequest)
        customPhrasesSet = getAllCustomPhrasesSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert custom phrases: \(error.localizedDescription)")
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
    }
    
    saveContext(didSucceed: {
        customPhrasesSet = getAllCustomPhrasesSet()
    })
}
