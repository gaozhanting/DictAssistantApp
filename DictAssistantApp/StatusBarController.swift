//
//  StatusBarController.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var contentPanel: NSPanel
    
    init(_ entryPanel: NSPanel) {
        self.contentPanel = entryPanel
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "Assistant")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(toggleContentPanel(sender:))
            statusBarButton.target = self
        }
    }
    
    @objc func toggleContentPanel(sender: AnyObject) {
        if contentPanel.isVisible {
            contentPanel.performClose(sender)
        } else {
            contentPanel.orderFrontRegardless()
        }
    }
}
