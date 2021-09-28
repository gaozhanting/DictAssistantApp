//
//  GlobalWindows.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/25.
//

import Foundation
import Cocoa
import SwiftUI

// Auto save selected slot frame settings
private class CCDelegate: NSObject, NSWindowDelegate {
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        myPrint(">>windowDidMove")
        updateSelectedSlot()
        myPrint("<<updateSelectedSlot windowDidMove")
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        myPrint(">>windowDidResize")
        updateSelectedSlot()
        myPrint("<<updateSelectedSlot windowDidResize")
    }
}
private let ccDelegate = CCDelegate()

private func updateSelectedSlot() {
    let slots = getAllSlots()
    for slot in slots {
        if slot.isSelected {
            var settings = dataToSettings(slot.settings!)!
            settings.contentFrame = contentWindow.frame
            settings.cropperFrame = cropperWindow.frame
            slot.settings = settingsToData(settings)
            saveContext()
            myPrint("did save slot")
            return
        }
    }
}

// global windows
// MARK: - content window
var contentWindow: NSPanel!
func syncContentWindowShadow(from isShowWindowShadow: Bool) {
    if isShowWindowShadow {
        contentWindow.invalidateShadow()
        contentWindow.hasShadow = true
    } else {
        contentWindow.invalidateShadow()
        contentWindow.hasShadow = false
    }
}

func initContentWindow() {
    // this rect is just the very first rect of the window, it will automatically stored the window frame info by system
    contentWindow = ContentPanel.init(
        contentRect: NSRect(x: 100, y: 100, width: 200, height: 600),
        name: "portraitWordsPanel"
    )
    
    contentWindow.delegate = ccDelegate
            
    let isShowWindowShadow = UserDefaults.standard.bool(forKey: IsShowWindowShadowKey)
    syncContentWindowShadow(from: isShowWindowShadow)

    contentWindow.close()
}

// MARK: - cropper window
var cropperWindow: NSWindow!
func syncCropperView(from cropperStyle: CropperStyle) {
    switch cropperStyle {
    case .closed:
        cropperWindow.contentView = NSHostingView(rootView: EmptyView())
        cropperWindow.close()
    case .rectangle:
        cropperWindow.contentView = NSHostingView(rootView: RectangleCropperView())
        cropperWindow.orderFrontRegardless()
    case .leadingBorder:
        cropperWindow.contentView = NSHostingView(rootView: LeadingBorderCropperView())
        cropperWindow.orderFrontRegardless()
    }
}

func initCropperWindow() {
    cropperWindow = CropperWindow.init(
        contentRect: NSRect(x: 300, y: 300, width: 600, height: 200),
        name: "cropperWindow"
    )
    
    cropperWindow.delegate = ccDelegate

    cropperWindow.close()
}

// MARK: - toast window
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
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
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
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            toastWindow.close()
        }
    }
}
