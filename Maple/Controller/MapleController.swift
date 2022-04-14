//
//  MapleController.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import Foundation
import Zip
import SwiftUI

/// Controls all Leafs, and their running status
class MapleController: ObservableObject {
    
    /// Shared MapleController singleton
    static let shared: MapleController = MapleController()
    
    /// File Manager singleton for this class, simplicity's sake
    final private let fManager: FileManager = .default
    
    //MARK: Public state management
    @Published var installedLeaves: [Leaf] = []
    
    //MARK: Private state management
    private var installerWindow: NSWindow? = nil
    
    /// Creates a Leaf object from a file
    /// - Parameter file: URL of the file, wherever it is stored on disk
    /// - Returns: Optional Leaf object, if no errors are thrown
    func installFile(_ file: URL) -> Leaf? {
        
        //Move it to internal storage
        let internalLoc: URL? = self.fManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tmpInstallLeaf2.zip")
        
        guard let _ = internalLoc else { return nil }
        
        do {
            try self.fManager.copyItem(at: file , to: internalLoc!)
            print("Internal Location: " + internalLoc!.absoluteString)
        } catch {
            print("Couldn't copy file to local storage: ", error)
            return nil
        }
        
        //Decompress .mapleleaf file to a folder containing .sap and .dylib
        var unzippedPackageURL: URL?
        do {
            unzippedPackageURL = try Zip.quickUnzipFile(internalLoc!)
        } catch {
            print("Error decompressing file: ", error)
            return nil
        }
        
        guard let _ = unzippedPackageURL else {
            
            return nil
        }
        
        var items: [String]? = nil
        do {
            items = try self.fManager.contentsOfDirectory(atPath: unzippedPackageURL!.absoluteString.replacingOccurrences(of: "file://", with: ""))
        } catch {
            print("Couldn't get contents: ", error)
            return nil
        }
        
        var containingFolder: String? = nil
        
        for f in items! {
            if f.first != "." && !f.contains("__") {
                containingFolder = f
            }
        }
        
        guard let _ = containingFolder else {
            print("Could not find a valid containing folder")
            return nil
        }
        
        // Sap file is located at unzipped + folder-name + "info.sap"
        var sapInfo: [String]? = nil
        do {
            sapInfo = (String(data: try Data(contentsOf: unzippedPackageURL!.appendingPathComponent(containingFolder! + "/info.sap")), encoding: .utf8) ?? "FAILURE").components(separatedBy: "\n")
            
        } catch {
            print("Could not get the info.sap data; Throwing ", error)
        }
        
        guard let _ = sapInfo else {
            print("Sap Info could not be found")
            return nil
        }
        
        // Create a Leaf object
        var resultLeaf: Leaf? = Leaf()
        
        // Process the .sap file to get all information about it
        for line in sapInfo! {
            resultLeaf?.add(field: line)
        }
        
        // Get the internal methods which are hooked for the user to verify
        // TODO: Create a script which can read into the dylib to parse which methods are hooked!
        
        // Clean up!
        try? self.fManager.removeItem(at: internalLoc!)
        try? self.fManager.removeItem(at: unzippedPackageURL!)
        
        // Return the Leaf object which holds all this information
        return resultLeaf
    }
    
    /// Responsible for installing a Leaf
    /// Saves the data to on device storage(permanent)
    /// Adds to an observable list
    /// - Parameter leaf: Leaf object to install
    func installLeaf(_ leaf: Leaf) {
        if self.installedLeaves.contains(where: { leaf.leafID == $0.leafID }) {
            print("You can't install two of the same tweaks")
            return
        }
        
        // Add this to the live list
        self.installedLeaves.append(leaf)
        
        // TODO: Add this leaf to permanent storage
    }
    
    /// Opens a seperate window which hosts the installer program
    /// - Used to install a new Leaf
    public func openWindowToInstallLeaf() {
        print("Opening a new window so you can install the thing")
        
        if self.installerWindow == nil {
            self.installerWindow = NSWindow(contentViewController: NSHostingController(rootView: InstallerView()))
            self.installerWindow?.setContentSize(NSSize(width: 600, height: 400))
            self.installerWindow?.title = "Maple: Install a new leaf"
            self.installerWindow?.styleMask = [.titled, .closable, .resizable, .miniaturizable]
            self.installerWindow?.minSize = NSSize(width: 600, height: 400)
            self.installerWindow?.contentMinSize = NSSize(width: 600, height: 400)
        }
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.installerWindow?.makeKey()
        self.installerWindow?.orderFrontRegardless()
        
        // Hide the menu bar app in case they overlap
        StatusBarController.shared?.hidePopover(self);
    }
    
    /// Close an open install window
    public func closeInstallWindow() {
        if self.installerWindow != nil {
            self.installerWindow!.close()
            self.installerWindow = nil
        }
    }
}
