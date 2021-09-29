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
    
    knownWordsPanel.setFrameAutosaveName("knownWordsPanel")
    
    knownWordsPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    knownWordsPanel.isReleasedWhenClosed = false
}

extension MenuSelectors {
    @objc public class func showKnownWordsPanel() {
        let knownWordsView = KnownWordsView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.removeMultiFromKnownWords, removeMultiFromKnownWords)
            .environment(\.addMultiToKnownWords, addMultiToKnownWords)
        
        knownWordsPanel.contentView = NSHostingView(rootView: knownWordsView)
        knownWordsPanel.orderFrontRegardless()
    }
}
