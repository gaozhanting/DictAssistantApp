//
//  KnownPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var knownPanel: NSPanel!

func initKnownPanel() {
    knownPanel = EditingPanel(
        contentRect: editPanelFrame,
        name: NSLocalizedString("Known Panel", comment: "")
    )
    knownPanel.close()
}

extension AppDelegate {
    @objc func showKnownPanel() {
        let view = KnownView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
        
        knownPanel.contentView = NSHostingView(rootView: view)
        knownPanel.orderFrontRegardless()
    }
}
