//
//  ExtraDictionariesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var extraDictionariesPanel: NSPanel!
func initExtraDictionariesPanel() {
    extraDictionariesPanel = NSPanel.init(
        contentRect: NSRect(x: 200, y: 100, width: 400, height: 600),
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
    
    extraDictionariesPanel.setFrameAutosaveName("extraDictionariesPanel")
    
    extraDictionariesPanel.collectionBehavior.insert(.fullScreenAuxiliary)
}

extension AppDelegate {
    @objc func showExtraDictionariesPanel() {
        let extraDictionariesView = DictionariesView()
        
        extraDictionariesPanel.contentView = NSHostingView(rootView: extraDictionariesView)
        extraDictionariesPanel.orderFrontRegardless()
    }
}
