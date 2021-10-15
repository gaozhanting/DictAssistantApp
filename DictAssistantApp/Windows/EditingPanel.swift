//
//  EditingPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa

class EditingPanel: NSPanel {
    init(contentRect: NSRect, name: String) {
        super.init(
            contentRect: contentRect,
            styleMask: [
                .nonactivatingPanel,
                .titled,
                .closable,
                .miniaturizable,
                .resizable,
                .utilityWindow,
            ],
            backing: .buffered,
            defer: false
        )
        
        self.setFrameAutosaveName(name)
        
        self.title = name
        
        self.level = .floating
        
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        
        self.isReleasedWhenClosed = false
    }
}
