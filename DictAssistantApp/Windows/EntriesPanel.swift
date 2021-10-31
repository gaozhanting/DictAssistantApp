//
//  EntriesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var entriesPanel: NSPanel!

func initEntriesPanel() {
    entriesPanel = EditingPanel(
        contentRect: editPanelFrame,
        name: NSLocalizedString("Entries Panel", comment: "")
    )
    entriesPanel.close()
}

extension AppDelegate {
    @objc func showEntriesPanel() {
        let view = EntriesView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
        
        entriesPanel.contentView = NSHostingView(rootView: view)
        entriesPanel.orderFrontRegardless()
    }
}
