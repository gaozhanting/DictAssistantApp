//
//  KnownWordsPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// for cache for running query
var knownWordsSet: Set<String> = getAllKnownWordsSet()

private func getAllKnownWordsSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let knownWords = results.map { $0.word! }
        return Set.init(knownWords)
    } catch {
        logger.error("Failed to fetch all known words: \(error.localizedDescription)")
        return Set()
    }
}

func batchInsertKnownWords(_ words: [String]) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: WordStats.entity(),
        objects: words.map { word in
            ["word": word]
        }
    )
    
    do {
        try context.execute(insertRequest)
    } catch {
        logger.error("Failed to batch insert known words:\(error.localizedDescription)")
    }
    
    knownWordsSet = getAllKnownWordsSet()
    trCallBack()
    showKnownWordsPanelX()
}

func removeMultiKnownWords(_ words: [String]) {
    let context = persistentContainer.viewContext
    
    for word in words {
        let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
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
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
    })
}

func batchDeleteAllKnownWords() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = WordStats.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
    } catch {
        logger.error("Failed to batch delete all known words: \(error.localizedDescription)")
    }
    
    knownWordsSet = getAllKnownWordsSet()
    trCallBack()
    showKnownWordsPanelX()
}

func addKnownWord(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let newWordStatus = WordStats(context: context)
            newWordStatus.word = word
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
    }
    saveContext(didSucceed: {
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
    })
}

func removeKnownWord(_ word: String) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            context.delete(result)
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
    }
    saveContext(didSucceed: {
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
    })
}
