//
//  Utilities.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/6/24.
//

import Foundation
import AppKit.NSColor
import os

extension String {
    // I see hyphen also as a phrase
    var isPhrase: Bool {
        self.contains(" ") || self.contains("-")
    }
}

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

let logger = Logger(subsystem: "com.gaozhanting.DictAssistantApp", category: "main")

func timeElapsed(info: String, _ closure: () -> Void) {
    let startingPoint = Date()
    closure()
    logger.info("time elapsed of \(info, privacy: .public): \(-startingPoint.timeIntervalSinceNow, privacy: .public) seconds")
}
