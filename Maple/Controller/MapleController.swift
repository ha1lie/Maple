//
//  MapleController.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import Foundation
import SwiftUI

class MapleController: ObservableObject {
    
    static let shared: MapleController = MapleController()
    
    //MARK: Public state management
    @Published var installedLeaves: [Leaf] = []
    
    //MARK: Private state management
    private var installerWindow: NSWindow? = nil
    
    func installLeaf() {
        
    }
    
    /// Opens a seperate window which hosts the installer program
    /// - Used to install a new Leaf
    public func openWindowToInstallLeaf() {
        print("Opening a new window so you can install the thing")
        
        if self.installerWindow == nil {
            self.installerWindow = NSWindow(contentViewController: NSHostingController(rootView: InstallerView()))
            self.installerWindow?.setContentSize(NSSize(width: 400, height: 300))
            self.installerWindow?.title = "Maple: Install a new leaf"
            self.installerWindow?.styleMask = [.titled, .closable, .resizable, .miniaturizable]
            self.installerWindow?.minSize = NSSize(width: 400, height: 300)
            self.installerWindow?.contentMinSize = NSSize(width: 400, height: 300)
            self.installerWindow?.collectionBehavior = .canJoinAllSpaces
        }
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.installerWindow?.makeKey()
        self.installerWindow?.orderFrontRegardless()
        
        // Hide the menu bar app in case they overlap
        StatusBarController.shared?.hidePopover(self);
    }
}
