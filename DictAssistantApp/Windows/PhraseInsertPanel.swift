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
    phraseInsertPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 50),
        name: "Phrase Insert")
}

func showPhraseInsertPanel() {
    let view = PhraseInsertView()
    phraseInsertPanel.contentView = NSHostingView(rootView: view)
    phraseInsertPanel.center()
    phraseInsertPanel.orderFrontRegardless()
}
