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
    
    let nlpMenu = NSMenu(title: NSLocalizedString("NLP", comment: ""))
    nlpMenu.addItem(withTitle: NSLocalizedString("Show Noises Panel", comment: ""), action: #selector(AppDelegate.showNoisesPanel), keyEquivalent: "")
    nlpMenu.addItem(withTitle: NSLocalizedString("Show Phrases Panel", comment: ""), action: #selector(AppDelegate.showPhrasePanel), keyEquivalent: "")
    let nlpMenuItem = NSMenuItem(title: NSLocalizedString("NLP", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(nlpMenuItem)
    menu.setSubmenu(nlpMenu, for: nlpMenuItem)
    
    let dictionaryMenu = NSMenu(title: NSLocalizedString("Dictionary", comment: ""))
    dictionaryMenu.addItem(withTitle: NSLocalizedString("Show Known Panel", comment: ""), action: #selector(AppDelegate.showKnownPanel), keyEquivalent: "")
    dictionaryMenu.addItem(withTitle: NSLocalizedString("Show Entries Panel", comment: ""), action: #selector(AppDelegate.showEntriesPanel), keyEquivalent: "")
    dictionaryMenu.addItem(withTitle: NSLocalizedString("Show Dict Build Panel", comment: ""), action: #selector(AppDelegate.showDictBuildPanel), keyEquivalent: "")
    let dictionaryMenuItem = NSMenuItem(title: NSLocalizedString("Dictionary", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(dictionaryMenuItem)
    menu.setSubmenu(dictionaryMenu, for: dictionaryMenuItem)
    
    let helpMenu = NSMenu(title: NSLocalizedString("Help", comment: ""))
    helpMenu.addItem(withTitle: NSLocalizedString("Show Onboarding Panel", comment: ""), action: #selector(AppDelegate.onboarding), keyEquivalent: "")
    let helpMenuItem = NSMenuItem(title: NSLocalizedString("Help", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(helpMenuItem)
    menu.setSubmenu(helpMenu, for: helpMenuItem)
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Quit Freedom English", comment: ""), action: #selector(AppDelegate.exit), keyEquivalent: "q"))
    
    statusItem.menu = menu
}

extension AppDelegate {
    @objc func exit() {
        NSApplication.shared.terminate(self)
    }
}
