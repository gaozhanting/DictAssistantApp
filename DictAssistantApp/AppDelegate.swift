//
//  AppDelegate.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import Cocoa
import SwiftUI
import DataBases
import CoreData
import CryptoKit
import Foundation
import Vision
import KeyboardShortcuts

private func appUpdate() {
    let existingVersion = UserDefaults.standard.string(forKey: "CurrentVersion") // may nil
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String // not nil
    if existingVersion != appVersion {
        logger.info("do app update")
        batchDeleteAllSlots()
        UserDefaults.standard.setValue(appVersion, forKey: "CurrentVersion")
        
        // customize code
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("All Slots Deleted!", comment: "")
        alert.informativeText = NSLocalizedString("Because when updating the App, the slot data may becomes incompatible, we need to delete all slots. Sorry for the trouble.", comment: "")
        alert.runModal()
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // Notice order
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        return // for swiftui preview
        
        // deprecated, updating app version, run appUpdate
//        batchDeleteAllSlots() // run when clear slot (when defaults delete com.gaozhanting.DictAssistantApp) (because slot is not compatible)
        
        // must first
        initAllUserDefaultsIfNil()
        
        // start: just simple windows(closed) and menu; no states
        initCropperWindow()
        initContentWindow()
        
        initToastWindow()
        
        initPhraseInsertPanel()
        initEntryUpsertPanel()
        
        initPhrasePanel()
        initEntriesPanel()
        initNoisesPanel()
        initKnownPanel()
        initDictInstallPanel()
        
        initOnboardingPanel()
        
        constructMenuBar()
        // end
        
        if !UserDefaults.standard.bool(forKey: IsFinishedOnboardingKey) {
            // init core data
            batchResetDefaultNoises()
            batchResetDefaultPhrases()
            batchDeleteAllKnown() // should init at onboarding
            batchDeleteAllEntries()
            batchDeleteAllSlots()
            
            // show UI
            self.onboarding() // when onboarding end, set IsFinishedOnboardingKey true
        } else {
            // not run appUpdate when first launch (means not finished Onboarding)
            appUpdate()
        }
                
        // some functions registers
        combineWindows()
        combineForRestartScreenCapture()
        combineEnglishSettings()
        autoSaveSlotSettings() // has states

        registerGlobalKey()
        
        // this will use state showing swiftUI, although not displayed
        fixFirstTimeLanuchOddAnimationByImplicitlyShowIt() // takes 0.35s
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    // to learn:
//    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
//        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
//        return persistentContainer.viewContext.undoManager
//    }
}

extension AppDelegate {
    // MARK: changeFont trigger from FontPanel
    // must adding @IBAction; otherwise will not be called when user select fonts from FontPanel
    @IBAction func changeFont(_ sender: NSFontManager?) {
        guard let sender = sender else { return assertionFailure() }
        let newFont = sender.convert(defaultNSFont)
        
        // hack to resolve the FontPanel issue, .SFNS-Regular can't be found in FontPanel, it is auto changed based on ".AppleSystemUIFont", which is wierd.
        let fontName = newFont.fontName == ".SFNS-Regular" ?
            defaultFontName :
            newFont.fontName
        
        UserDefaults.standard.setValue(fontName, forKey: FontNameKey)
        UserDefaults.standard.setValue(newFont.pointSize, forKey: FontSizeKey)
    }
}
