//
//  SlotPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import CoreData

// MARK: - Core Data (Slot)
func getAllSlots() -> [Slot] {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<Slot> = Slot.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return results
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        return []
    }
}

// for development, call at applicationDidFinishLaunching
func deleteAllSlots() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Slot")
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

    do {
        try context.execute(deleteRequest)
    } catch {
        logger.error("Failed to delete all slots: \(error.localizedDescription)")
    }
}
