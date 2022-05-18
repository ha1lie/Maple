//
//  AppDelegate.swift
//  Maple
//
//  Created by Hallie on 4/3/22.
//

import Cocoa
import SwiftUI
import Blessed
import SecureXPC

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover = NSPopover()
    var statusBar: StatusBarController?
    
    let sharedConstants: SharedConstants
    let helperMonitor: HelperToolMonitor
    
    override init() {
        do {
            self.sharedConstants = try SharedConstants(caller: .app)
            self.helperMonitor = HelperToolMonitor(constants: self.sharedConstants)
        } catch {
            print("One or more property list configuration issues exist. Please check the PropertyListModifier.swift " +
                  "script is run as part of the build process for both the app and helper tool targets. This script " +
                  "will automatically create all of the necessary configurations.")
            print("Issue: \(error)")
            exit(-1)
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
        
        self.helperMonitor.determineStatus()
        
        guard let bl = self.sharedConstants.bundledLocation else { return }
        
        if self.helperMonitor.helperToolBundleVersion == nil || (try! HelperToolInfoPropertyList(from: bl).version) > self.helperMonitor.helperToolBundleVersion! {
            DispatchQueue.main.async {
                let xpcService: XPCClient = XPCClient.forMachService(named: self.sharedConstants.machServiceName)
                xpcService.sendMessage(bl, to: SharedConstants.updateRoute) { response in
                    if case .failure(let error) = response {
                        switch error {
                        case .connectionInterrupted:
                            return
                        default:
                            print("Update error: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        
        self.helperMonitor.determineStatus()
        
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

