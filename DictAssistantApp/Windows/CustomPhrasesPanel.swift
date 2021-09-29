//
//  CustomPhrasesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var customPhrasesPanel: NSPanel!
func initCustomPhrasesPanel() {
    customPhrasesPanel = NSPanel.init(
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
    
    customPhrasesPanel.setFrameAutosaveName("customPhrasesPanel")
    
    customPhrasesPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    customPhrasesPanel.isReleasedWhenClosed = false
}

extension AppDelegate {
    @objc func showCustomPhrasesPanel() {
        let customPhrasesView = CustomPhrasesView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.addMultiCustomPhrases, addMultiCustomPhrases)
            .environment(\.removeMultiCustomPhrases, removeMultiCustomPhrases)
        
        customPhrasesPanel.contentView = NSHostingView(rootView: customPhrasesView)
        customPhrasesPanel.orderFrontRegardless()
    }
}
