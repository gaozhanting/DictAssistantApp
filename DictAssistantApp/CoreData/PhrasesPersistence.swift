//
//  PhrasesPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Cocoa
import CoreData
import DataBases

// for cache for running query
var phrasesSet: Set<String> = getAllPhrasesSet()

private func getAllPhrasesSet() -> Set<String> {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()

    do {
        let phrases = try context.fetch(fetchRequest)
        return Set.init(
            phrases.map { $0.word! }
        )
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return Set()
    }
}

func batchResetDefaultPhrases(didSucceed: @escaping () -> Void = {}) {
    batchDeleteAllPhrases() {
        batchInsertPhrases(phrasesDB) {
            didSucceed()
        }
    }
}

func batchInsertPhrases(_ words: [String], didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let insertRequest = NSBatchInsertRequest(
        entity: Phrase.entity(),
        objects: words.map { word in
            ["word": word]
        }
    )
    insertRequest.resultType = .objectIDs
    
    do {
        let result = try context.execute(insertRequest) as? NSBatchInsertResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSInsertedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        phrasesSet = getAllPhrasesSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch insert  phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

// because we need nothingChanged info.
func multiInsertPhrases(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    if words.count > 1000 {
        batchInsertPhrases(words, didSucceed: didSucceed)
    } else {
        insertMultiPhrases(words, didSucceed: didSucceed, nothingChanged: nothingChanged)
    }
}

func insertMultiPhrases(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    for word in words {
        let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word = %@", word)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let newPhrase = Phrase(context: context)
                newPhrase.word = word
            }
        } catch {
            logger.error("Failed to fetch request: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
        }
    }
    
    saveContext(didSucceed: {
        phrasesSet = getAllPhrasesSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
      nothingChanged()
    })
}

func batchDeleteAllPhrases(didSucceed: @escaping () -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Phrase.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs
    
    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])
        
        phrasesSet = getAllPhrasesSet()
        trCallBack()
        didSucceed()
    } catch {
        logger.error("Failed to batch delete all  phrases: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}

// can't batch delete specific collection ?!
func removeMultiPhrases(
    _ words: [String],
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping() -> Void = {}
) {
    let context = persistentContainer.viewContext
    
    for word in words {
        let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
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
        phrasesSet = getAllPhrasesSet()
        trCallBack()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}

func addPhrase(_ word: String,
               didSucceed: @escaping () -> Void = {},
               nothingChanged: @escaping() -> Void = {}) {
    let context = persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<Phrase> = Phrase.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "word = %@", word)
    fetchRequest.fetchLimit = 1
    
    do {
        let results = try context.fetch(fetchRequest)
        if results.isEmpty {
            let newPhrase = Phrase(context: context)
            newPhrase.word = word
        }
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
    
    saveContext(didSucceed: {
        phrasesSet = getAllPhrasesSet()
        didSucceed()
    }, nothingChanged: {
        nothingChanged()
    })
}
