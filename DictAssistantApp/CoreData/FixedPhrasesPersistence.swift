//
//  FixedPhrases.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// global big constants
/*
 count is 366,502
 
 all contains belows
 2 words: 262,321 71%
 3 words:  74,687 20%
 4 words:  21,620 5%
 5 words:   6,898 2%
 // ignores >5 when do phrase detect programming
 */
//let phrasesDB = Vocabularies.readToSet(from: "phrases_from_ecdict.txt") // take 2.28s, too long

// only once at development, from txt file to sql file
func batchInsertFixedPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext
//    context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

    let insertRequest = NSBatchInsertRequest(
        entity: FixedPhrase.entity(),
        objects: phrases.map { phrase in
            ["phrase": phrase]
        }
    )

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch insert all fixed Phrases: \(error.localizedDescription)")
    }
}

// only for development
func batchDeleteAllFixedPhrases() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FixedPhrase")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try context.execute(deleteRequest)
    } catch {
        logger.error("Failed to insert all fixed Phrases: \(error.localizedDescription)")
    }
}

// for cache for running query
let fixedPhrasesSet: Set<String> = getAllFixedPhrasesSet()

private func getAllFixedPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FixedPhrase> = FixedPhrase.fetchRequest()
//    fetchRequest.propertiesToFetch = ["phrase"]
    
    do {
        let fixedPhrase = try context.fetch(fetchRequest)
        let phrases = fixedPhrase.map { $0.phrase! }
        return Set.init(phrases)
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return Set()
    }
}
