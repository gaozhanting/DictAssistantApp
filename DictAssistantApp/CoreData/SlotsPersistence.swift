//
//  SlotsPersistence.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Foundation
import Cocoa
import CoreData

func getAllSlots() -> [Slot] {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<Slot> = Slot.fetchRequest()
    
    do {
        let results = try context.fetch(fetchRequest)
        return results
    } catch {
        logger.error("Failed to fetch request: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
        return []
    }
}

func batchDeleteAllSlots() {
    let context = persistentContainer.viewContext

    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Slot.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    deleteRequest.resultType = .resultTypeObjectIDs

    do {
        let result = try context.execute(deleteRequest) as? NSBatchDeleteResult
        
        let objectIDArray = result?.result as? [NSManagedObjectID]
        let changes = [NSDeletedObjectsKey: objectIDArray]
        NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes as [AnyHashable : Any], into: [context])

    } catch {
        logger.error("Failed to batch delete all slots: \(error.localizedDescription)")
        NSApplication.shared.presentError(error as NSError)
    }
}
