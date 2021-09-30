//
//  CustomDictPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var customDictPanel: NSPanel!

func initCustomDictPanel() {
    customDictPanel = NSPanel.init(
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
    
    customDictPanel.title = "Custom Dict"
    customDictPanel.setFrameAutosaveName("customDictPanel")
    
    customDictPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    customDictPanel.isReleasedWhenClosed = false
}

func showCustomDictPanelX() {
    let customDictView = CustomDictView()
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    
    customDictPanel.contentView = NSHostingView(rootView: customDictView)
    customDictPanel.orderFrontRegardless()
}

extension AppDelegate {
    @objc func showCustomDictPanel() {
        showCustomDictPanelX()
    }
}
