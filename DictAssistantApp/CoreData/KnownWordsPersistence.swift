//
//  KnownWordsPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// todo: how to make it effecient?
func getAllKnownWordsSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<WordStats> = WordStats.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let knownWords = results.map { $0.word! }
        return Set(knownWords)
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return Set()
    }
}

func addToKnownWords(_ word: String) {
    addMultiToKnownWords([word])
}

func addMultiToKnownWords(_ words: [String]) {
    let context = persistentContainer.viewContext
    
    for word in words {
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
    }
    saveContextWithChangingKnownWordsSideEffect()
}

func removeFromKnownWords(_ word: String) {
    removeMultiFromKnownWords([word])
}

func removeMultiFromKnownWords(_ words: [String]) {
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
    saveContextWithChangingKnownWordsSideEffect()
}

// for development, call at applicationDidFinishLaunching
func deleteAllKnownWords() {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "WordStats")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.viewContext)
    } catch {
        logger.error("Failed to delete all known words: \(error.localizedDescription)")
    }
    saveContextWithChangingKnownWordsSideEffect()
}

// MARK: - Core Data saveContext with side effect
func saveContextWithChangingKnownWordsSideEffect() {
    saveContext {
        allKnownWordsSetCache = getAllKnownWordsSet()
        let taggedWords = tagWords(cleanedWords)
        mutateDisplayedWords(taggedWords)
    }
}
