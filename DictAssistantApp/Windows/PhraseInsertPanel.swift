//
//  PhrasesInsertPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import Cocoa
import SwiftUI

var phraseInsertPanel: NSPanel!

func initPhraseInsertPanel() {
    phraseInsertPanel = NSPanel.init(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 50),
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
    
    phraseInsertPanel.title = "Phrase Insert"
    phraseInsertPanel.setFrameAutosaveName("phraseInsertPanel")
    phraseInsertPanel.collectionBehavior.insert(.fullScreenAuxiliary)
}

func showPhraseInsertPanel() {
    let phraseInsertView = PhraseInsertView()
    phraseInsertPanel.contentView = NSHostingView(rootView: phraseInsertView)
    phraseInsertPanel.center()
    phraseInsertPanel.orderFrontRegardless()
}
