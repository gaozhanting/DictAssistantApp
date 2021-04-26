//
//  AppDelegate.swift
//  DictAssistantApp
//
//  Created by Gao Cong on 2021/4/20.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar: StatusBarController?
    var popover = NSPopover.init()
    var wordsWindow: NSPanel!
    
    var timer: Timer = Timer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        func showWordsView() {
            wordsWindow.makeKeyAndOrderFront(nil)
        }
        func closeWordsView() {
            wordsWindow.close()
        }
        func screenCapture(_ timer: Timer) {
            let task = Process()
            task.launchPath = "/usr/sbin/screencapture"
            var arguments = [String]();
            arguments.append("-x")
            arguments.append("-R 100,100,500,300")
            arguments.append(NSHomeDirectory() + "/Documents/" + "abc.png")

            task.arguments = arguments
            task.launch()
        }
        func startScreenCapture() {
            timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: screenCapture(_:))
        }
        func stopScreenCapture() {
            timer.invalidate()
        }
        let popoverView = PopoverView(showWordsView: showWordsView, closeWordsView: closeWordsView, startScreenCapture: startScreenCapture, stopScreenCapture: stopScreenCapture)
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = NSHostingController(rootView: popoverView)
        
        let windowStyleMask: NSWindow.StyleMask = [
            .titled,
            .closable,
            .miniaturizable,
            .utilityWindow,
            .docModalWindow,
            .nonactivatingPanel
        ]
        wordsWindow = NSPanel.init(contentRect: NSMakeRect(1700,500,310,600),
                                  styleMask: windowStyleMask,
                                    backing: NSWindow.BackingStoreType.buffered,
                                      defer: false,
                                     screen: NSScreen.main)
        wordsWindow.title = "Words"
        
        let wordsView = WordsView()
        wordsWindow.contentView = NSHostingView(rootView: wordsView)
        
        statusBar = StatusBarController.init(popover, wordsWindow)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

