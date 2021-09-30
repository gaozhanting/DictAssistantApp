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

// how to refresh UI ? -> Notification(current not use)
func batchInsertCustomPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: CustomPhrase.entity(),
        objects: phrases.map { phrase in
            ["phrase": phrase]
        }
    )
    
    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch insert custom phrases: \(error.localizedDescription)")
    }
    
    customPhrasesSet = getAllCustomPhrasesSet()
    showCustomPhrasesPanelX()
}

// can't batch delete specific collection ?!
func removeMultiCustomPhrases(_ phrases: [String]) {
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
    
    saveContext {
        customPhrasesSet = getAllCustomPhrasesSet()
    }
}
