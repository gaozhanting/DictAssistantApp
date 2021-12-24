//
//  MiniEntryPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import Cocoa
import SwiftUI

var miniEntryPanel: NSPanel!

func initMiniEntryPanel() {
    miniEntryPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 400, height: 42),
        name: NSLocalizedString("Mini Entry Panel", comment: "")
    )
    miniEntryPanel.close()
}

func showMiniEntryPanel() {
    let view = MiniEntryView()
    miniEntryPanel.contentView = NSHostingView(rootView: view)
    miniEntryPanel.center()
    miniEntryPanel.orderFrontRegardless()
}
