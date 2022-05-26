//
//  MapleController.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import Foundation
import Zip
import SwiftUI
import SecureXPC

/// Controls all Leafs, and their running status
class MapleController: ObservableObject {
    
    static let shared: MapleController = MapleController()
    
    private static let installedLeavesKey: String = "installedLeaves"
    private static let runnablesDir: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Runnables", isDirectory: true)
    private static let installedDir: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Installed", isDirectory: true)
    private static let preferencesDir: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Preferences", isDirectory: true)
    
    private let xpcService: XPCClient
    private let sharedConstants: SharedConstants
    private let bundledLocation: URL
    
    final private let fManager: FileManager = .default
    final private let uDefaults: UserDefaults = .standard
    
    private var installerWindow: NSWindow? = nil
    private var injecting: Bool = false
    private var runningLeaves: [Leaf] {
        get {
            return installedLeaves.filter({ $0.enabled && $0.isValid() })
        }
    }
    
    @Published var installedLeaves: [Leaf] = []
    @Published var canCurrentlyInject: Bool = false
    
    //MARK: General
    
    init() {
        guard let tsc = (NSApplication.shared.delegate as? AppDelegate)?.sharedConstants else {
            fatalError("Could not find AppDelegate's SharedConstants")
        }
        
        guard let bl = tsc.bundledLocation else {
            fatalError("Helper Tool Location Shouldn't Not Exist")
        }
        
        self.sharedConstants = tsc
        self.bundledLocation = bl
        self.xpcService = XPCClient.forMachService(named: sharedConstants.machServiceName)
    }
    
    /// Setup initial state for Maple Controller
    /// Also initialize injection for enabled Leaves
    public func configure() {
        self.installedLeaves = self.fetchLocallyStoredLeaves()
        self.startInjectingEnabledLeaves()
        
        // Make sure that the directories will exist when you need them... doesn't hurt to put them there now
        try? self.fManager.createDirectory(at: MapleController.runnablesDir, withIntermediateDirectories: true)
        try? self.fManager.createDirectory(at: MapleController.installedDir, withIntermediateDirectories: true)
        try? self.fManager.createDirectory(at: MapleController.preferencesDir, withIntermediateDirectories: true)
        
        if MaplePreferencesController.shared.developmentEnabled {
            MapleDevelopmentHelper.shared.configure()
        }
    }
    
    //MARK: Maple Injector Management
    
    /// Create contents of the listen file
    /// - Parameter pieces: Pieces of the listen file to pass in
    /// - Returns: Concatenated and formatted listen file
    private func listenContents(for pieces: [String: [String]]) -> String {
        var contents: String = ""
        for piece in pieces.keys {
            contents += piece
            for lib in pieces[piece]! {
                contents += " /Users/hallie/Library/Application Support/Maple/Runnables/\(lib)"
            }
            contents += "\n"
        }
        return contents
    }
    
    public func reloadInjection() {
        self.stopInjectingEnabledLeaves()
        self.startInjectingEnabledLeaves()
    }
    
    /// Begins injecting all enabled leaves
    public func startInjectingEnabledLeaves() {
        var procs: [String] = []
        
        // Create contents of listen.txt file
        var listenFile: [String : [String]] = [:]
        for leaf in self.runningLeaves {
            for i in 0..<leaf.targetBundleID!.count {
                if let _ = listenFile[leaf.targetBundleID![i]] {
                    listenFile[leaf.targetBundleID![i]]!.append("\(leaf.leafID!)/\(leaf.libraryName!)")
                } else {
                    listenFile[leaf.targetBundleID![i]] = ["\(leaf.leafID!)/\(leaf.libraryName!)"]
                }
            }
            procs.append(contentsOf: leaf.targetBundleID!)
        }
        
        // Write listen.txt file
        MapleFileHelper.shared.writeFile(withContents: self.listenContents(for: listenFile), atLocation: SharedConstants.listenFile)
        
        // Spin up an instance of Maple-LibInjector with above file
        self.startMapleInjector()
        
        // Kill the processes, optionally check if the user would like them to be restarted
        do {
            try self.killProcesses(withBIDs: procs)
        } catch {
            print("ERRORED while attempting to begin injection: \(error)")
        }
        
    }

    /// Stops all leaves from running
    public func stopInjectingEnabledLeaves() {
        self.stopMapleInjector()
        try? self.fManager.removeItem(at: SharedConstants.listenFile)
        
        var bids: [String] = []
        for leaf in self.runningLeaves {
            bids.append(contentsOf: leaf.targetBundleID!)
        }
        try? self.killProcesses(withBIDs: bids)
    }
    
    /// Starts up Maple-LibInjector with default listen file
    private func startMapleInjector() {
        let sema = DispatchSemaphore(value: 1)
        Task {
            do {
                let response = try await self.xpcService.send(to: SharedConstants.mapleInjectionBeginInjection)
                if response == nil {
                    print("Successfully began injection")
                } else {
                    print("Errored while beginning injection: \(response!)")
                }
            } catch {
                print("Failed to begin injection: \(error.localizedDescription)")
            }
            sema.signal()
        }
        sema.wait()
        self.injecting = true
    }
    
    /// Stops Maple-LibInjector from injecting
    private func stopMapleInjector() {
        let sema = DispatchSemaphore(value: 0)
        Task {
            do {
                let _ = try await self.xpcService.send(to: SharedConstants.mapleInjectionEndInjection)
                print("Successfully ended injection")
            } catch {
                print("Errored when ending injection: \(error)")
            }
            sema.signal()
        }
        sema.wait()
        self.injecting = false
    }
    
    /// Reloads Maple-LibInjector after changing a listen file
    private func reloadMapleInjector() {
        self.stopMapleInjector()
        self.startMapleInjector()
    }
    
    //MARK: Process Management
    
    /// Kills multiple processes
    /// - Parameter bids: BIDs of desired processes to end
    private func killProcesses(withBIDs bids: [String]) throws {
        for running in NSWorkspace.shared.runningApplications {
            if running.bundleIdentifier != nil && bids.contains(running.bundleIdentifier!) {
                let kp = Process()
                kp.launchPath = "/bin/kill"
                print("\(running.processIdentifier)")
                kp.arguments = ["-9", "\(running.processIdentifier)"]
                kp.launch()
                kp.waitUntilExit()
            }
        }
    }
    
    /// Kills a given process if it's currently running
    /// - Parameter bid: Bundle ID of a process you would like to kill
    func killProcess(withBID bid: String) throws {
        for running in NSWorkspace.shared.runningApplications {
            if running.bundleIdentifier == bid {
                let kp = Process()
                kp.launchPath = "/bin/kill"
                print("\(running.processIdentifier)")
                kp.arguments = ["-9", "\(running.processIdentifier)"]
                kp.launch()
                kp.waitUntilExit()
            }
        }
    }
    
    //MARK: Leaf Management
    
    /// Creates a Leaf object from a file
    /// - Parameter file: URL of the file, wherever it is stored on disk
    /// - Returns: Optional Leaf object, if no errors are thrown
    func installFile(_ file: URL) throws -> Leaf? {
        let internalLoc: URL = MapleController.installedDir.appendingPathComponent("tmpInstallable.zip")
        let unzippedPackageURL: URL = MapleController.installedDir.appendingPathComponent("installing", isDirectory: true)
        
        defer {
            // Clean up!
            try? self.fManager.removeItem(at: internalLoc)
            try? self.fManager.removeItem(at: unzippedPackageURL)
        }
        
        do {
            try self.fManager.copyItem(at: file , to: internalLoc)
        } catch {
            throw InstallError.fileDidntExist
        }
        
        do {
            try Zip.unzipFile(internalLoc, destination: unzippedPackageURL, overwrite: true, password: nil)
        } catch {
            throw InstallError.compressionError
        }
        
        
        let items: [String] = MapleFileHelper.shared.contentsOf(Directory: unzippedPackageURL)
        
        var containingFolder: String? = nil
        
        for f in items {
            if f.first != "." && !f.contains("__") {
                containingFolder = f
            }
        }
        
        guard let _ = containingFolder else { throw InstallError.invalidDirectories }
        
        // Sap file is located at unzipped + folder-name + "info.sap"
        let sapRes: String? = MapleFileHelper.shared.readFile(atLocation: unzippedPackageURL.appendingPathComponent(containingFolder! + "/info.sap"))
        
        guard let _ = sapRes else { throw InstallError.invalidSap }
        
        let sapInfo: [String] = sapRes!.components(separatedBy: "\n")
        
        // Create a Leaf object
        let resultLeaf: Leaf? = Leaf()
        
        // Process the .sap file to get all information about it
        for line in sapInfo {
            try resultLeaf?.add(field: line)
        }
        
        if resultLeaf?.isValid() ?? false {
            do {
                try self.fManager.copyItem(at: internalLoc, to: MapleController.installedDir.appendingPathComponent("/\(resultLeaf!.leafID ?? "").mapleleaf"))
            } catch {
                print("Could not copy to installed directory")
            }
            
            do {
                try self.fManager.createDirectory(at: MapleController.runnablesDir.appendingPathComponent("/\(resultLeaf!.leafID!)"), withIntermediateDirectories: true)
                try self.fManager.copyItem(at: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/\(resultLeaf!.libraryName!)"), to: MapleController.runnablesDir.appendingPathComponent("/\(resultLeaf!.leafID!)/\(resultLeaf!.libraryName!)"))
            } catch {
                // Could not copy dylib to runnables directory
                print("Failed to copy dylib to runnables directory: \(error.localizedDescription)")
            }
        }
        
        // TODO: Create a script which can read into the dylib to parse which methods are hooked!
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
        self.updateLocallyStoredLeaves()
    }
    
    /// Save self.installedLeaves to UserDefaults
    func updateLocallyStoredLeaves() {
        let encodedData = try? JSONEncoder().encode(self.installedLeaves)
        
        guard let _ = encodedData else { print("Could not encode self.installedLeaves"); return }
        
        if encodedData!.isEmpty {
            print("Failed to properly convert leaves to Data")
            return
        }
        
        self.uDefaults.set(encodedData, forKey: MapleController.installedLeavesKey)
    }
    
    /// Get locally stored + installed Leaves
    /// - Returns: Array of Leaf objects, empty if none are installed
    private func fetchLocallyStoredLeaves() -> [Leaf] {
        if let encodedData = UserDefaults.standard.data(forKey: MapleController.installedLeavesKey) {
            if let leaves = try? JSONDecoder().decode([Leaf].self, from: encodedData) {
                return leaves
            }
        }
        return []
    }
    
    //MARK: App Management
    
    /// Opens a seperate window which hosts the installer program
    /// - Used to install a new Leaf
    public func openWindowToInstallLeaf() {
        self.installerWindow = NSWindow(contentViewController: NSHostingController(rootView: InstallerView()))
        self.installerWindow?.setContentSize(NSSize(width: 600, height: 400))
        self.installerWindow?.title = "Maple: Install a new leaf"
        self.installerWindow?.styleMask = [.titled, .closable, .resizable, .miniaturizable]
        self.installerWindow?.minSize = NSSize(width: 600, height: 400)
        self.installerWindow?.contentMinSize = NSSize(width: 600, height: 400)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.installerWindow?.makeKey()
        self.installerWindow?.orderFrontRegardless()
        
        // Hide the menu bar app in case they overlap
        StatusBarController.shared?.hidePopover(self);
    }
    
    /// Open a window to change and modify Maple settings
    public func openSettingsWindow() {
        self.installerWindow = NSWindow(contentViewController: NSHostingController(rootView: SettingsView()))
        self.installerWindow?.setContentSize(NSSize(width: 600, height: 400))
        self.installerWindow?.title = "Maple Settings"
        self.installerWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        self.installerWindow?.minSize = NSSize(width: 600, height: 400)
        self.installerWindow?.contentMinSize = NSSize(width: 600, height: 400)
        
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
