//
//  EntryUpsertPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import Cocoa
import SwiftUI

var entryUpsertPanel: NSPanel!

func initEntryUpsertPanel() {
    entryUpsertPanel = NSPanel.init(
        contentRect: NSRect(x: 200, y: 100, width: 400, height: 50),
        styleMask: [
            .nonactivatingPanel,
            .titled,
            .closable,
            .miniaturizable,
            .resizable,
            .utilityWindow,
        ],
        backing: .buffered,
        defer: false
        //            screen: NSScreen.main
    )
    
    entryUpsertPanel.title = "Entry Upsert"
    entryUpsertPanel.setFrameAutosaveName("entryUpsertPanel")
    entryUpsertPanel.collectionBehavior.insert(.fullScreenAuxiliary)
}

func showEntryUpsertPanel() {
    let entryUpsertView = EntryUpsertView()
    entryUpsertPanel.contentView = NSHostingView(rootView: entryUpsertView)
    entryUpsertPanel.center()
    entryUpsertPanel.orderFrontRegardless()
}
