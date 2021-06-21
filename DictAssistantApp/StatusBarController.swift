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
    private var toggleContent: () -> Void
    
    init(_ toggleContent:@escaping () -> Void) {
        self.toggleContent = toggleContent
        statusBar = NSStatusBar.init()
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "character.book.closed", accessibilityDescription: nil)
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            statusBarButton.action = #selector(toggleTheContent(sender:))
            statusBarButton.target = self
        }
    }
    
    @objc func toggleTheContent(sender: AnyObject) {
        toggleContent()
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "character.book.closed.fill", accessibilityDescription: nil)
        }
    }
}
