//
//  Persistent.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// MARK: - Core Data
var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "WordStatistics")
    container.loadPersistentStores { description, error in
        if let error = error {
            logger.error("Unable to load persistent stores: \(error.localizedDescription)")
        }
    }
    return container
}()

func saveContext(_ completionHandler: () -> Void = {}) {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
            completionHandler()
        } catch {
            logger.info("Failed to save context: \(error.localizedDescription)")
        }
    }
}
