//
//  CustomPhrases.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// MARK: - Core Data (Custom Phrases)
//func generatePharsesSet() -> Set<String> {
//    phrasesDB.union(getAllCustomPhrasesSet())
//}

func getAllCustomPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        let customePhrases = results.map { $0.phrase! }
        return Set(customePhrases)
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return Set()
    }
}

func isPhraseInCustomPhrases(_ phrase: String) -> Bool {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
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

func addMultiCustomPhrases(_ phrases: [String]) {
    let context = persistentContainer.viewContext
    
    for phrase in phrases {
        let fetchRequest: NSFetchRequest<CustomPhrase> = CustomPhrase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "phrase = %@", phrase)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newCustomPhrase = CustomPhrase(context: context)
                newCustomPhrase.phrase = phrase
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
        }
    }
    saveContext()
}

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
    saveContext()
}
