//
//  KnownWordsPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
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
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchInsertKnownWords(_ words: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: WordStats.entity(),
        objects: words.map { word in
            ["word": word]
        }
    )
    
    do {
        try context.execute(insertRequest)
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert known words:\(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

func removeMultiKnownWords(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
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
            NSApplication.shared.presentError(error as NSError)
        }
    }
    saveContext(didSucceed: {
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
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
        NSApplication.shared.presentError(error as NSError)
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
        NSApplication.shared.presentError(error as NSError)
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
        NSApplication.shared.presentError(error as NSError)
    }
    saveContext(didSucceed: {
        knownWordsSet = getAllKnownWordsSet()
        trCallBack()
    })
}
