//
//  self.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/12.
//

import Cocoa
import SwiftUI

var cropperWindow: NSWindow!

let defaultCropperFrame = NSRect(x: 310, y: 500, width: 600, height: 200)

func initCropperWindow() {
    cropperWindow = CropperWindow.init(
        contentRect: defaultCropperFrame,
        name: "cropperWindow"
    )
    
    cropperWindow.delegate = ccDelegate
    
    cropperWindow.close()
}

func syncCropperView(from cropperStyle: CropperStyle) {
    switch cropperStyle {
    case .empty:
        cropperWindow.contentView = NSHostingView(rootView: EmptyView())
    case .strokeBorder:
        cropperWindow.contentView = NSHostingView(rootView: StrokeBorderCropperView().environmentObject(hlBox)
        )
    case .rectangle:
        cropperWindow.contentView = NSHostingView(rootView: RectangleCropperView())
    case .leadingBorder:
        cropperWindow.contentView = NSHostingView(rootView: LeadingBorderCropperView())
    case .trailingBorder:
        cropperWindow.contentView = NSHostingView(rootView: TrailingBorderCropperView())
    }
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
                
        self.hasShadow = false
        
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
    }
}
