//
//  self.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/12.
//

import Cocoa
import SwiftUI

var cropperWindow: NSWindow!

func initCropperWindow() {
    cropperWindow = CropperWindow.init(
        contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
        name: "cropperWindow"
    )
    
    cropperWindow.delegate = cropperWindowDelegate
}

func syncCropperView(from cropperStyle: CropperStyle) {
    switch cropperStyle {
    case .closed:
        cropperWindow.contentView = NSHostingView(rootView: EmptyView())
    case .rectangle:
        cropperWindow.contentView = NSHostingView(rootView: RectangleCropperView())
    case .leadingBorder:
        cropperWindow.contentView = NSHostingView(rootView: LeadingBorderCropperView())
    case .trailingBorder:
        cropperWindow.contentView = NSHostingView(rootView: TrailingBorderCropperView())
    }
    cropperWindow.orderFrontRegardless()
}

// Auto save selected slot frame settings
private let cropperWindowDelegate = CropperWindowDelegate()

private class CropperWindowDelegate: NSObject, NSWindowDelegate {
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    func updateSelectedSlot() {
        let slots = getAllSlots()
        for slot in slots {
            if slot.isSelected {
                var settings = dataToSettings(slot.settings!)!
                settings.contentFrame = cropperWindow.frame
                slot.settings = settingsToData(settings)
                saveContext()
                myPrint("did save slot cropper frame")
                return
            }
        }
    }
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
