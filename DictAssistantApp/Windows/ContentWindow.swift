//
//  self.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/12.
//

import Cocoa

// MARK: - content window
var contentWindow: NSPanel!

let defaultContentFrame = NSRect(x: 100, y: 100, width: 200, height: 600)

func initContentWindow() {
    // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
    contentWindow = ContentWindow.init(
        contentRect: defaultContentFrame,
        name: "portraitWordsPanel"
    )
    
    contentWindow.delegate = ccDelegate
            
    let isShowWindowShadow = UserDefaults.standard.bool(forKey: IsShowWindowShadowKey)
    syncContentWindowShadow(from: isShowWindowShadow)
    
    contentWindow.close()
}

func syncContentWindowShadow(from isShowWindowShadow: Bool) {
    if isShowWindowShadow {
        contentWindow.hasShadow = true
    } else {
        contentWindow.hasShadow = false
    }
}

private class ContentWindow: NSPanel {
    init(contentRect: NSRect, name: String) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .fullSizeContentView,
                .miniaturizable,
                .resizable,
                .utilityWindow,
                .borderless,
            ],
            backing: .buffered,
            defer: false
//            screen: NSScreen.main
        )
        
        // Set this if you want the panel to remember its size/position
        self.setFrameAutosaveName(name)
        
        // Allow the pannel to be on top of almost all other windows
        //        self.isFloatingPanel = true
        self.level = .floating
        
        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior.insert(.fullScreenAuxiliary)
//        self.collectionBehavior.insert(.moveToActiveSpace)
//        self.collectionBehavior.insert(.managed)
//        self.collectionBehavior.insert(.fullScreenAllowsTiling)
        
        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        
        // Since there is no titlebar make the window moveable by click-dragging on the background
        self.isMovableByWindowBackground = true
        
        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.toolbarButton)?.isHidden = true
                
        self.hasShadow = false
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
    }
}
