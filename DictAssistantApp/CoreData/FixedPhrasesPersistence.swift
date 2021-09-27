//
//  FixedPhrases.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// MARK: - Core Data (Fixed Phrases)
func getAllFixedPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FixedPhrase> = FixedPhrase.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let customePhrases = results.map { $0.phrase! }
        return Set(customePhrases)
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return Set()
    }
}

func batchInsertFixedPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext
    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    let insertRequest = NSBatchInsertRequest(
        entity: FixedPhrase.entity(),
        objects: phrases.map { phrase in
            ["phrase": phrase]
        }
//        objects: [
//            ["phrase": "p1"],
//            ["phrase": "p2"]
//        ]
    )

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch insert all fixed Phrases: \(error.localizedDescription)")
    }
    saveContext()
}

func batchDeleteFixedPhrases(_ phrases: [String]) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FixedPhrase")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
    } catch {
        logger.error("Failed to insert all fixed Phrases: \(error.localizedDescription)")
    }
    saveContext()
}

func addMultiFixedPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext
    
    for phrase in phrases {
        let fetchRequest: NSFetchRequest<FixedPhrase> = FixedPhrase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newFixedPhrase = FixedPhrase(context: context)
                newFixedPhrase.phrase = phrase
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
        }
    }
    saveContext()
}

func isPhraseInFixedPhrases(_ phrase: String) -> Bool {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FixedPhrase> = FixedPhrase.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.first != nil {
            return true
        }
        return false
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return false
    }
}
