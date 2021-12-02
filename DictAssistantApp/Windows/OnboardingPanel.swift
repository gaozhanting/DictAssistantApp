//
//  OnboardingPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var onboardingPanel: NSWindow!

func initOnboardingPanel() {
    let contentRect = NSRect(x: 200, y: 100, width: 650, height: 530)
    let name = NSLocalizedString("Onboarding", comment: "")
    
    onboardingPanel = NSWindow.init(
        contentRect: contentRect,
        styleMask: [
            .titled,
            .closable,
            .miniaturizable,
            .resizable,
        ],
        backing: .buffered,
        defer: false
    )
    
    onboardingPanel.setFrameAutosaveName(name)
    onboardingPanel.title = name
    onboardingPanel.isReleasedWhenClosed = false
    
    onboardingPanel.close()
}

extension AppDelegate {
    @objc func onboarding() {
        let view = OnboardingView(pages: OnboardingPage.allCases)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.endOnboarding, endOnboarding)
            .frame(width: 650, height: 530)
        
        onboardingPanel.contentView = NSHostingView(rootView: view)
        onboardingPanel.center()
        onboardingPanel.orderFrontRegardless()
    }
}

func endOnboarding() {
    onboardingPanel.close()
}
