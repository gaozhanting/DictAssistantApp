//
//  PhrasesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var phrasePanel: NSPanel!

let editPanelFrame = NSRect(x: 200, y: 100, width: 300, height: 600)

func initPhrasePanel() {
    phrasePanel = EditingPanel(
        contentRect: editPanelFrame,
        name: NSLocalizedString("Phrases Panel", comment: "")
    )
    phrasePanel.close()
}

extension AppDelegate {
    @objc func showPhrasePanel() {
        let view = PhrasesView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
        
        phrasePanel.contentView = NSHostingView(rootView: view)
        phrasePanel.orderFrontRegardless()
    }
}
    
