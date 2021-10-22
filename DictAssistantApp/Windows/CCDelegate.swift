//
//  GlobalWindows.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/25.
//

import Cocoa

// Auto save selected slot frame settings
let ccDelegate = CCDelegate()

class CCDelegate: NSObject, NSWindowDelegate {
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
}

private func updateSelectedSlot() {
    let slots = getAllSlots()
    for slot in slots {
        if slot.isSelected {
//            slot.contentFrame = contentWindow.frame
//            slot.cropperFrame = cropperWindow.frame
//            saveContext()
            myPrint("did save slot")
            return
        }
    }
}
