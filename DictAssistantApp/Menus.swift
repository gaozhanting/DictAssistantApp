//
//  Menus.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa
import SwiftUI

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

let menu = NSMenu()

func constructMenuBar() {
    
    statusItem.button?.image = NSImage(named: "EmptyIcon")
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Preferences...", comment:  ""), action: #selector(AppDelegate.showPreferences), keyEquivalent: ","))
    menu.addItem(NSMenuItem.separator())
    
    let englishMenu = NSMenu(title: NSLocalizedString("English", comment: ""))
    englishMenu.addItem(withTitle: NSLocalizedString("Show Noises Panel", comment: ""), action: #selector(AppDelegate.showNoisesPanel), keyEquivalent: "")
    englishMenu.addItem(withTitle: NSLocalizedString("Show Phrases Panel", comment: ""), action: #selector(AppDelegate.showPhrasePanel), keyEquivalent: "")
    englishMenu.addItem(withTitle: NSLocalizedString("Show Known Panel", comment: ""), action: #selector(AppDelegate.showKnownPanel), keyEquivalent: "")
    englishMenu.addItem(withTitle: NSLocalizedString("Show Entries Panel", comment: ""), action: #selector(AppDelegate.showEntriesPanel), keyEquivalent: "")
    englishMenu.addItem(withTitle: NSLocalizedString("Show Dict Install Panel", comment: ""), action: #selector(AppDelegate.showDictInstallPanel), keyEquivalent: "")
    let englishMenuItem = NSMenuItem(title: NSLocalizedString("English", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(englishMenuItem)
    menu.setSubmenu(englishMenu, for: englishMenuItem)
    
    let helpMenu = NSMenu(title: NSLocalizedString("Help", comment: ""))
    helpMenu.addItem(withTitle: NSLocalizedString("Show Onboarding Panel", comment: ""), action: #selector(AppDelegate.onboarding), keyEquivalent: "")
    helpMenu.addItem(withTitle: NSLocalizedString("Watch Tutorial Video", comment: ""), action: #selector(AppDelegate.openTutorialVideoURL), keyEquivalent: "")
    let helpMenuItem = NSMenuItem(title: NSLocalizedString("Help", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(helpMenuItem)
    menu.setSubmenu(helpMenu, for: helpMenuItem)
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: ""), action: #selector(AppDelegate.exit), keyEquivalent: ""))
    
    statusItem.menu = menu
}

extension AppDelegate {
    @objc func openTutorialVideoURL() {
        guard let url = URL(string: "https://www.youtube.com/watch?v=afHqGHDfZKA") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

extension AppDelegate {
    @objc func exit() {
        NSApplication.shared.terminate(self)
    }
}
