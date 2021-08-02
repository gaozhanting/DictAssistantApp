//
//  VisualEffectView.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/7/25.
//

import SwiftUI

struct VisualEffectView: NSViewRepresentable {
    let visualEffect: NSVisualEffectView
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        var visualEffectView = NSVisualEffectView()
        visualEffectView = visualEffect
        visualEffectView.state = NSVisualEffectView.State.active
        return visualEffectView
    }

    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
    }
}

let selectionContentVisualEffect: NSVisualEffectView = {
    let ve = NSVisualEffectView()
    ve.material = .underWindowBackground
    ve.blendingMode = .behindWindow
    return ve
}()

let toastVisualEffect: NSVisualEffectView = {
    let ve = NSVisualEffectView()
    ve.material = .hudWindow
    ve.blendingMode = .behindWindow
    return ve
}()
