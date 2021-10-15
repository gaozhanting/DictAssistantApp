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
    entryUpsertPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 400, height: 50),
        name: "Entry Upsert Panel")
}

func showEntryUpsertPanel() {
    let view = EntryUpsertView()
    entryUpsertPanel.contentView = NSHostingView(rootView: view)
    entryUpsertPanel.center()
    entryUpsertPanel.orderFrontRegardless()
}
