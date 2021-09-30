//
//  KnownWordsPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var knownWordsPanel: NSPanel!

func initKnownWordsPanel() {
    knownWordsPanel = NSPanel.init(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
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
    
    knownWordsPanel.title = "Known Words"
    knownWordsPanel.setFrameAutosaveName("knownWordsPanel")
    
    knownWordsPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    knownWordsPanel.isReleasedWhenClosed = false
}

func showKnownWordsPanelX() {
    let knownWordsView = KnownWordsView()
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    
    knownWordsPanel.contentView = NSHostingView(rootView: knownWordsView)
    knownWordsPanel.orderFrontRegardless()
}

extension AppDelegate {
    @objc func showKnownWordsPanel() {
        showKnownWordsPanelX()
    }
}
