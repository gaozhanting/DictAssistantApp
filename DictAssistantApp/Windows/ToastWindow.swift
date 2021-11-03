//
//  ToastWindow.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/2.
//

import Cocoa
import SwiftUI

var toastWindow: NSWindow!

func initToastWindow() {
    toastWindow = ToastWindow.init(
        contentRect: NSRect(x: 300, y: 300, width: 300, height: 300),
        name: "toastWindow"
    )
    
    toastWindow.center()
    toastWindow.close()
}

func toastOn() {
    if UserDefaults.standard.bool(forKey: ShowToastToggleKey) {
        toastWindow.contentView = NSHostingView(
            rootView: ToastOnView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea())
        toastWindow.center()
        toastWindow.orderFrontRegardless()
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            toastWindow.close()
        }
    }
}

func toastOff() {
    if UserDefaults.standard.bool(forKey: ShowToastToggleKey) {
        toastWindow.contentView = NSHostingView(
            rootView: ToastOffView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea())
        toastWindow.center()
        toastWindow.orderFrontRegardless()
        
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { timer in
            toastWindow.close()
        }
    }
}

private class ToastWindow: NSWindow {
    init(contentRect: NSRect, name: String) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .titled,
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
        
        // While we may set a title for the window, don't show it
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        
        // Since there is no titlebar make the window moveable by click-dragging on the background
//        self.isMovableByWindowBackground = true
        
        // Keep the panel around after closing since I expect the user to open/close it often
        self.isReleasedWhenClosed = false
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true
        self.standardWindowButton(.toolbarButton)?.isHidden = true
    }
}
