//
//  Menus.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/9/29.
//

import Cocoa

let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

let menu = NSMenu()

class MenuSelectors { } // container for objc selector

func constructMenuBar() {
    statusItem.button?.image = NSImage(
        systemSymbolName: "d.circle",
        accessibilityDescription: nil
    )
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Preferences...", comment:  ""), action: #selector(MenuSelectors.showPreferences), keyEquivalent: ","))
    
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Show Known Words Panel", comment: ""), action: #selector(MenuSelectors.showKnownWordsPanel), keyEquivalent: ""))
    
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Show Custom Dict Panel", comment: ""), action: #selector(MenuSelectors.showCustomDictPanel), keyEquivalent: ""))
    
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Show Custom Phrases Panel", comment: ""), action: #selector(MenuSelectors.showCustomPhrasesPanel), keyEquivalent: ""))
    
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Show Extra Dictionaries Panel", comment: ""), action: #selector(MenuSelectors.showExtraDictionariesPanel), keyEquivalent: ""))
    
    menu.addItem(NSMenuItem.separator())
    
    let helpMenu = NSMenu(title: NSLocalizedString("Help", comment: ""))
    helpMenu.addItem(withTitle: NSLocalizedString("Show Onboarding Panel", comment: ""), action: #selector(MenuSelectors.onboarding), keyEquivalent: "")
    helpMenu.addItem(withTitle: NSLocalizedString("Watch Tutorial Video", comment: ""), action: #selector(MenuSelectors.openTutorialVideoURL), keyEquivalent: "")
    let helpMenuItem = NSMenuItem(title: NSLocalizedString("Help", comment: ""), action: nil, keyEquivalent: "")
    menu.addItem(helpMenuItem)
    menu.setSubmenu(helpMenu, for: helpMenuItem)
    
    menu.addItem(NSMenuItem.separator())
    
    menu.addItem(NSMenuItem(title: NSLocalizedString("Quit", comment: ""), action: #selector(MenuSelectors.exit), keyEquivalent: ""))
    
    statusItem.menu = menu
}

extension MenuSelectors {
    @objc public class func openTutorialVideoURL() {
        guard let url = URL(string: "https://www.youtube.com/watch?v=afHqGHDfZKA") else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}

extension MenuSelectors {
    @objc public class func exit() {
        NSApplication.shared.terminate(self)
    }
}
