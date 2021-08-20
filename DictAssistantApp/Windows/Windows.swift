//
//  windows.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/2.
//

import Foundation
import Cocoa
import SwiftUI

// global windows

// MARK: - content window
var contentWindow: NSPanel!
func toggleContentShadow() {
    if UserDefaults.standard.bool(forKey: IsShowWindowShadowKey) {
        contentWindow.hasShadow = true
        contentWindow.invalidateShadow()
    } else {
        contentWindow.hasShadow = false
    }
}

// MARK: - cropper window
var cropperWindow: NSWindow!
func toggleCropperView() {
    switch CropperStyle(rawValue: UserDefaults.standard.integer(forKey: CropperStyleKey))! {
    case .closed:
//        cropperWindow.contentView = NSHostingView(rootView: EmptyView())
        cropperWindow.close()
    case .rectangle:
        cropperWindow.contentView = NSHostingView(rootView: RectCropperView())
        cropperWindow.orderFrontRegardless()
    }
}

// MARK: - toast window
var toastWindow: NSWindow!
func initToastWindow() {
    toastWindow = ToastWindow.init(
        contentRect: NSRect(x: 300, y: 300, width: 300, height: 300),
        name: "toastWindow2"
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
