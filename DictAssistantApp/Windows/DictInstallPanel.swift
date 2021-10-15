//
//  DictInstallPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var dictInstallPanel: NSPanel!

func initDictInstallPanel() {
    dictInstallPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 450, height: 200),
        name: "Dict Install Panel"
    )
}

extension AppDelegate {
    @objc func showDictInstallPanel() {
        let view = DictInstallWithInfoView()
        
        dictInstallPanel.contentView = NSHostingView(rootView: view)
        dictInstallPanel.center()
        dictInstallPanel.orderFrontRegardless()
    }
}
