//
//  KnownMiniPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/12/22.
//

import Foundation
import SwiftUI

var miniKnownPanel: NSPanel!

func initMiniKnownPanel() {
    miniKnownPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 40),
        name: NSLocalizedString("Mini Known Panel", comment: "")
    )
    miniKnownPanel.close()
}

func toggleMiniKnownPanel() {
    if miniKnownPanel.isVisible {
        miniKnownPanel.close()
    } else {
        let view = MiniKnownView()
        miniKnownPanel.contentView = NSHostingView(rootView: view)
        miniKnownPanel.orderFrontRegardless()
    }
}
