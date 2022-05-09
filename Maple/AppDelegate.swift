//
//  AppDelegate.swift
//  Maple
//
//  Created by Hallie on 4/3/22.
//

import Cocoa
import SwiftUI
import Blessed

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover = NSPopover()
    var statusBar: StatusBarController?
    
    let sharedConstants: SharedConstants
    
    override init() {
        do {
            self.sharedConstants = try SharedConstants(caller: .app)
        } catch {
            print("One or more property list configuration issues exist. Please check the PropertyListModifier.swift " +
                  "script is run as part of the build process for both the app and helper tool targets. This script " +
                  "will automatically create all of the necessary configurations.")
            print("Issue: \(error)")
            exit(-1)
        }
        
        // Setup authorization right
        do {
            let right = SharedConstants.exampleRight
            if !(try right.isDefined()) {
                let description = ProcessInfo.processInfo.processName + " would like to perform a secure action."
                try right.createOrUpdateDefinition(rules: [CannedAuthorizationRightRules.authenticateAsAdmin],
                                                   descriptionKey: description)
            }
        } catch {
            print("Unable to create authorization right: \(SharedConstants.exampleRight.name)")
            print("Issue: \(error)")
            exit(-2)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let contentView = HomeScreen()
        
        self.popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover.contentSize = NSSize(width: 360, height: 300)
        
        self.statusBar = StatusBarController(self.popover)
        
        DispatchQueue.main.async {
            NSApp.windows.first?.close()
        }
        
        MapleController.shared.configure()
        MapleController.shared.openSettingsWindow()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        MapleController.shared.stopInjectingEnabledLeaves()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApp.setActivationPolicy(.accessory)
        return false
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

