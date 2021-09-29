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