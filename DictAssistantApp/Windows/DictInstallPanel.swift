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
        name: NSLocalizedString("Dict Install Panel", comment: "")
    )
    dictInstallPanel.close()
}

extension AppDelegate {
    @objc func showDictInstallPanel() {
        let view = DictInstallWithInfoView()
        
        dictInstallPanel.contentViewController = NSHostingController(rootView: view)
        dictInstallPanel.center()
        dictInstallPanel.orderFrontRegardless()
    }
}
