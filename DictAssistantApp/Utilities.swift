//
//  Utilities.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import Foundation
import AppKit.NSColor

func colorToData(_ color: NSColor) -> Data? {
    if let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) {
        return data
    } else {
        return nil
    }
}

func dataToColor(_ data: Data) -> NSColor? {
    let unarchivedData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    let color = unarchivedData as NSColor?
    return color
}
