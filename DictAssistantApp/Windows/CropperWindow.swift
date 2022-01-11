//
//  self.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/12.
//

import Cocoa
import SwiftUI

var cropperWindow: NSWindow!

let (defaultCropperFrame, defaultContentFrame): (NSRect, NSRect) = {
    if let mainScreen = NSScreen.main {
        let defaultCropperWidth: CGFloat = 800.0
        let defaultCropperHeight: CGFloat = 400.0

        let defaultContentWidth: CGFloat = 300.0
        let defaultContentHeight: CGFloat = 600.0

        let cropperX = mainScreen.frame.midX - defaultCropperWidth * 0.5
        let cropperY = mainScreen.frame.midY - defaultCropperHeight * 0.5

        let gap: CGFloat = 10.0

        return (
            NSRect(x: cropperX,
                   y: cropperY,
                   width: defaultCropperWidth,
                   height: defaultCropperHeight),
            NSRect(x: cropperX + defaultCropperWidth + gap,
                   y: cropperY - abs(defaultContentHeight - defaultCropperHeight),
                   width: defaultContentWidth,
                   height: defaultContentHeight)
        )
    } else {
        return (
            NSRect(x: 100, y: 500, width: 600, height: 200),
            NSRect(x: 100 + 600 + 10, y: 100, width: 200, height: 600)
        )
    }
}()

func initCropperWindow() {
    cropperWindow = CropperWindow.init(
        contentRect: defaultCropperFrame,
        name: "cropperWindow"
    )
    
    cropperWindow.delegate = ccDelegate
    
    cropperWindow.close()
}

func syncCropperView(from cropperStyle: CropperStyle) {
    cropperWindow.contentView = NSHostingView(rootView: CropperViewWithHighlight().environmentObject(hlBox))
    cropperWindow.orderFrontRegardless()
}

private class CropperWindow: NSWindow {
    init(contentRect: NSRect, name: String) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .fullSizeContentView,
                .resizable,
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
        
        self.hasShadow = true
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
    }
}
