//
//  CustomDictPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

func getEntry(of word: String) -> CustomDict? {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if let result = results.first {
            return result
        } else {
            return nil
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return nil
    }
}

func addMultiEntriesToCustomDict(entries: [Entry]) {
    let context = persistentContainer.viewContext
    
    for entry in entries {
        let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", entry.word)
        fetchRequest.fetchLimit = 1
        
        do { // todo: how to update core data item?
            let customDicts = try context.fetch(fetchRequest)
            if let customDict = customDicts.first { // update
                customDict.word = entry.word
                customDict.trans = entry.trans
            } else { // insert
                let newEntry = CustomDict(context: context)
                newEntry.word = entry.word
                newEntry.trans = entry.trans
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
        }
    }
    saveContextWithChangingCustomDictSideEffect()
}

func removeMultiWordsFromCustomDict(words: [String]) {
    let context = persistentContainer.viewContext

    for word in words {
        let fetchRequest: NSFetchRequest<CustomDict> = CustomDict.fetchRequest()
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
    saveContextWithChangingCustomDictSideEffect()
}

func saveContextWithChangingCustomDictSideEffect() {
    saveContext {
        cachedDict = [:]
        let taggedWords = tagWords(cleanedWords)
        mutateDisplayedWords(taggedWords)
    }
}
