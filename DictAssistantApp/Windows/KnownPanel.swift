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
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
        name: NSLocalizedString("Known Panel", comment: "")
    )
}

extension AppDelegate {
    @objc func showKnownPanel() {
        let view = KnownView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
        
        knownPanel.contentView = NSHostingView(rootView: view)
        knownPanel.orderFrontRegardless()
    }
}
