//
//  PersistentStack.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/27.
//

import Cocoa
import CoreData

let persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "app")
    container.loadPersistentStores { description, error in
        if let error = error {
            logger.error("Unable to load persistent stores: \(error.localizedDescription)")
            NSApplication.shared.presentError(error as NSError)
        }
    }
    return container
}()

func saveContext(
    didSucceed: @escaping () -> Void = {},
    nothingChanged: @escaping () -> Void = {}
) {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
            didSucceed()
        } catch {
            logger.error("Failed to save context: \(error.localizedDescription)")
            
            // Customize this code block to include application-specific recovery steps.
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
        }
    } else {
        nothingChanged()
    }
}
