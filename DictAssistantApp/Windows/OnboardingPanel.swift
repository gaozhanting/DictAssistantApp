//
//  OnboardingPanel.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

var onboardingPanel: NSPanel!

func initOnboardingPanel() {
    onboardingPanel = NSPanel.init(
        contentRect: NSRect(x: 200, y: 100, width: 650, height: 530),
        styleMask: [
            .nonactivatingPanel,
            .titled,
        ],
        backing: .buffered,
        defer: false
    )
    
    onboardingPanel.title = NSLocalizedString("Onboarding", comment: "")
    onboardingPanel.setFrameAutosaveName("onboardingPanel")
    onboardingPanel.close()
}

extension AppDelegate {
    @objc func onboarding() {
        let onboardingView = OnboardingView(pages: OnboardingPage.allCases)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.endOnboarding, endOnboarding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(width: 650, height: 530)
        
        onboardingPanel.contentViewController = NSHostingController(rootView: onboardingView)
        onboardingPanel.center()
        onboardingPanel.orderFrontRegardless()
    }
}

func endOnboarding() {
    onboardingPanel.close()
}
