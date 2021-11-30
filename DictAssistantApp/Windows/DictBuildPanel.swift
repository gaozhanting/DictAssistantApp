//
//  DictBuildPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var dictBuildPanel: NSPanel!

func initDictBuildPanel() {
    dictBuildPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 650, height: 200),
        name: NSLocalizedString("Dict Build Panel", comment: "")
    )
    dictBuildPanel.close()
}

extension AppDelegate {
    @objc func showDictBuildPanel() {
        let view = DictBuildWithInfoView()
        
        dictBuildPanel.contentViewController = NSHostingController(rootView: view)
        dictBuildPanel.center()
        dictBuildPanel.orderFrontRegardless()
    }
}
