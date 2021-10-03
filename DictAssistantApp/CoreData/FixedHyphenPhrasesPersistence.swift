//
//  FixedHyphenPhrasesPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/3.
//

import Foundation
import Cocoa
import CoreData
import DataBases

// for cache for running query
var fixedHyphenPhrasesSet: Set<String> = getAllFixedHyphenPhrasesSet()

private func getAllFixedHyphenPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<FixedHyphenPhrase> = FixedHyphenPhrase.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return Set.init(
            results.map { $0.phrase! }
        )
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

/*
 count is 55,835
 */
//let hyphenPhrasesDB = Vocabularies.readToArray(from: "hyphen_phrases.txt")

// only once at development, from txt file to sql file
func batchInsertFixedHyphenPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: FixedHyphenPhrase.entity(),
        objects: phrases.map { phrase in
            ["phrase": phrase]
        }
    )

    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch insert all fixed hyphen phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    fixedHyphenPhrasesSet = getAllFixedHyphenPhrasesSet()
}

// only for development
func batchDeleteAllFixedHyphenPhrases() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FixedHyphenPhrase.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    do {
        try context.execute(deleteRequest)
    } catch {
        logger.error("Failed to insert all fixed hyphen phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    fixedHyphenPhrasesSet = getAllFixedHyphenPhrasesSet()
}
