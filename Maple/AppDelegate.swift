//
//  AppDelegate.swift
//  Maple
//
//  Created by Hallie on 4/3/22.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    
    var popover = NSPopover()
    var statusBar: StatusBarController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let contentView = HomeScreen()
        
        self.popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover.contentSize = NSSize(width: 360, height: 300)
        
        self.statusBar = StatusBarController(self.popover)
        
        DispatchQueue.main.async {
            NSApp.windows.first?.close()
        }
        
        MapleController.shared.openWindowToInstallLeaf()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

