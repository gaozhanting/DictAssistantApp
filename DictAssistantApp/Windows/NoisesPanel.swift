//
//  NoisesPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/10/15.
//

import Cocoa
import SwiftUI

var noisesPanel: NSPanel!

func initNoisesPanel() {
    noisesPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 300, height: 600),
        name: "Noises Panel"
    )
}

extension AppDelegate {
    @objc func showNoisesPanel() {
        let view = NoisesView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)

        noisesPanel.contentView = NSHostingView(rootView: view)
        noisesPanel.orderFrontRegardless()
    }
}