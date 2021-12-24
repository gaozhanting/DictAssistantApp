//
//  MiniPhrasesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/11.
//

import Cocoa
import SwiftUI

var miniPhrasePanel: NSPanel!

func initMiniPhrasePanel() {
    miniPhrasePanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 42),
        name: NSLocalizedString("Mini Phrase Panel", comment: "")
    )
    miniPhrasePanel.close()
}

func showMiniPhrasePanel() {
    let view = MiniPhraseView()
    miniPhrasePanel.contentView = NSHostingView(rootView: view)
    miniPhrasePanel.center()
    miniPhrasePanel.orderFrontRegardless()
}
