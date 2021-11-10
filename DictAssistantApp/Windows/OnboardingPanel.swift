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
    onboardingPanel = EditingPanel(
        contentRect: NSRect(x: 200, y: 100, width: 650, height: 530),
        name: NSLocalizedString("Onboarding", comment: "")
    )
    onboardingPanel.standardWindowButton(.closeButton)?.isHidden = true
    onboardingPanel.standardWindowButton(.miniaturizeButton)?.isHidden = true
    onboardingPanel.standardWindowButton(.zoomButton)?.isHidden = true
    onboardingPanel.standardWindowButton(.toolbarButton)?.isHidden = true
    
    onboardingPanel.close()
}

extension AppDelegate {
    @objc func onboarding() {
        let view = OnboardingView(pages: OnboardingPage.allCases)
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environment(\.endOnboarding, endOnboarding)
            .frame(width: 650, height: 530)
        
        onboardingPanel.contentViewController = NSHostingController(rootView: view)
        onboardingPanel.center()
        onboardingPanel.orderFrontRegardless()
    }
}

func endOnboarding() {
    onboardingPanel.close()
}
