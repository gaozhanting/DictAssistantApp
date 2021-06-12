//
//  self.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/12.
//

import Foundation
import Foundation
import Cocoa

class CropperWindow: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 100000, height: 100000),
            styleMask: [
                .nonactivatingPanel,
                .titled, // must be set, otherwise cropper not show!?
//                .closable, // disable the behavior of pressing esc key to close self, because we want it showing the cropper area always.
                .fullSizeContentView,
//                .fullScreen // cann't set fullScreen, this will show titlebar (especially using with some fullscreen app) // without this, cropper dimension y should plus 25 which is the height of titlebar // we want the background fullScreen, not draw its title bar
            ],
            backing: .buffered,
            defer: false
//            screen: NSScreen.main
        )
        
        // Set this if you want the panel to remember its size/position
        self.setFrameAutosaveName("self")
        
        // Allow the pannel to be on top of almost all other windows
        self.isFloatingPanel = true
        self.level = .floating
        
        // Allow the pannel to appear in a fullscreen space
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        
        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        
        // Since there is no titlebar make the window moveable by click-dragging on the background
//        self.isMovableByWindowBackground = true
        
        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false
        
        // Activate this if you want the window to hide once it is no longer focused
        //        self.hidesOnDeactivate = true
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.toolbarButton)?.isHidden = true

        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        
        self.center() // only first time centered
    }
}
