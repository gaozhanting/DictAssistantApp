//
//  GlobalWindows.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/8/25.
//

import Cocoa

// Auto save selected slot frame settings
let contentWindowDelegate = ContentWindowDelegate()
let cropperWindowDelegate = CropperWindowDelegate()

class ContentWindowDelegate: NSObject, NSWindowDelegate {
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    private func updateSelectedSlot() {
        let slots = getAllSlots()
        for slot in slots {
            if slot.isSelected {
                slot.contentFrame = rectToString(contentWindow.frame)
                saveContext()
                myPrint("did save slot content frame")
                return
            }
        }
    }
}

class CropperWindowDelegate: NSObject, NSWindowDelegate {
    // MARK: - Sync frame to selected Slot
    func windowDidMove(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    func windowDidResize(_ notification: Notification) { // content window && cropper window
        updateSelectedSlot()
    }
    
    private func updateSelectedSlot() {
        let slots = getAllSlots()
        for slot in slots {
            if slot.isSelected {
                slot.cropperFrame = rectToString(cropperWindow.frame)
                saveContext()
                myPrint("did save slot cropper frame")
                return
            }
        }
    }
}

func rectToString(_ rect: NSRect) -> String {
    let x = rect.origin.x
    let y = rect.origin.y
    let w = rect.size.width
    let h = rect.size.height
    
    return "\(x),\(y),\(w),\(h)"
}

func stringToRect(_ str: String) -> NSRect {
    let arr = str.split(separator: Character(","))
    let x = Double(arr[0])!
    let y = Double(arr[1])!
    let w = Double(arr[2])!
    let h = Double(arr[3])!
    
    return NSRect.init(x: x, y: y, width: w, height: h)
}
