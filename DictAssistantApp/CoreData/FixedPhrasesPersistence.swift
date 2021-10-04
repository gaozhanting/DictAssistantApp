//
//  FixedPhrases.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

// for cache for running query
var fixedPhrasesSet: Set<String> = getAllFixedPhrasesSet()

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
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

/*
 count is 366,502
 
 all contains belows
 2 words: 262,321 71%
 3 words:  74,687 20%
 4 words:  21,620 5%
 5 words:   6,898 2%
 // ignores >5 when do phrase detect programming
 */
//let phrasesDB = Vocabularies.read(from: "phrases.txt") // take 2.28s, too long

// only once at development, from txt file to sql file
func batchInsertFixedPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext

    let insertRequest = NSBatchInsertRequest(
        entity: FixedPhrase.entity(),
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
        
    } catch {
        logger.error("Failed to batch insert all fixed phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    fixedPhrasesSet = getAllFixedPhrasesSet()
}

// only for development
func batchDeleteAllFixedPhrases() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FixedPhrase.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
    } catch {
        logger.error("Failed to insert all fixed phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    fixedPhrasesSet = getAllFixedPhrasesSet()
}

