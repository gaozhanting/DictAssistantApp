//
//  CustomNoisesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/30.
//

import Cocoa
import SwiftUI

var customNoisesPanel: NSPanel!

func initCustomNoisesPanel() {
    customNoisesPanel = NSPanel.init(
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
    
    customNoisesPanel.title = "Custom Noises"
    customNoisesPanel.setFrameAutosaveName("customNoisesPanel")
    
    customNoisesPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    customNoisesPanel.isReleasedWhenClosed = false
}

func showCustomNoisesPanelX() {
    let customPhrasesView = CustomNoiseView()
        .environment(\.managedObjectContext, persistentContainer.viewContext)
    
    customNoisesPanel.contentView = NSHostingView(rootView: customPhrasesView)
    customNoisesPanel.orderFrontRegardless()
}

extension AppDelegate {
    @objc func showCustomNoisesPanel() {
        showCustomNoisesPanelX()
    }
}
