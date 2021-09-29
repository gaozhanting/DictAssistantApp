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
    
    customDictPanel.setFrameAutosaveName("customDictPanel")
    
    customDictPanel.collectionBehavior.insert(.fullScreenAuxiliary)
    customDictPanel.isReleasedWhenClosed = false
}

extension MenuSelectors {
    @objc public class func showCustomDictPanel() {
        let customDictView = CustomDictView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.addMultiEntriesToCustomDict, addMultiEntriesToCustomDict)
            .environment(\.removeMultiWordsFromCustomDict, removeMultiWordsFromCustomDict)
        
        customDictPanel.contentView = NSHostingView(rootView: customDictView)
        customDictPanel.orderFrontRegardless()
    }
}
