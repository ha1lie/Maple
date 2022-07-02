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
import MaplePreferences

/// Controls all Leafs, and their running status
class MapleController: ObservableObject {
    
    static let shared: MapleController = MapleController()
    
    private static let installedLeavesKey: String = "installedLeaves"
    static let runnablesDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Runnables", isDirectory: true)
    static let installedDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Installed", isDirectory: true)
    static let preferencesDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Preferences", isDirectory: true)
    static let hiddenInstallingDir: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/.installing", isDirectory: true)
    
    static let listenFile: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Runnables/listen.txt", isDirectory: false)
    
    private let xpcService: XPCClient
    private let sharedConstants: SharedConstants
    private let bundledLocation: URL
    
    final private let fManager: FileManager = .default
    final private let uDefaults: UserDefaults = .standard
    
    private var installerWindow: NSWindow? = nil
    private var injecting: Bool = false
    private var runningLeaves: [Leaf] {
        get {
            return installedLeaves.filter({ $0.enabled })
        }
    }
    
    @Published var installedLeaves: [Leaf] = []
    @Published var canCurrentlyInject: Bool = false
    
    //MARK: General
    
    init() {
        guard let tsc = (NSApplication.shared.delegate as? AppDelegate)?.sharedConstants else {
            MapleLogController.shared.local(log: "ERROR AppDelegate did not contain SharedConstants")
            fatalError("Could not find AppDelegate's SharedConstants")
        }
        
        guard let bl = tsc.bundledLocation else {
            MapleLogController.shared.local(log: "ERROR Helper tool's location did not exist within the bundle")
            fatalError("Helper Tool Location Shouldn't Not Exist")
        }
        
        self.sharedConstants = tsc
        self.bundledLocation = bl
        self.xpcService = XPCClient.forMachService(named: sharedConstants.machServiceName)
    }
    
    /// Setup initial state for Maple Controller
    /// Also initialize injection for enabled Leaves
    public func configure() {
        let fetched = self.fetchLocallyStoredLeaves()
        DispatchQueue.main.async {
            self.installedLeaves = fetched
            self.startInjectingEnabledLeaves()
        }
        
        // Make sure that the directories will exist when you need them... doesn't hurt to put them there now
        try? self.fManager.createDirectory(at: MapleController.runnablesDir, withIntermediateDirectories: true)
        try? self.fManager.createDirectory(at: MapleController.installedDir, withIntermediateDirectories: true)
        try? self.fManager.createDirectory(at: MapleController.preferencesDir, withIntermediateDirectories: true)
        try? self.fManager.createDirectory(at: MapleController.hiddenInstallingDir, withIntermediateDirectories: true)
        
        if MaplePreferencesController.shared.developmentEnabled {
            MapleDevelopmentHelper.shared.configure()
        }
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(injectorCrashHandler(notification:)), name: Notification.Name("maple.injector.crash"), object: nil)
    }
    
    /// Installs the injector to the shared location in /Library via the priv. tool
    public func installInjector() {
        self.xpcService.send(to: SharedConstants.installInjectorExecutable) { response in
            switch response {
            case .failure(let error):
                MapleLogController.shared.local(log: error.localizedDescription)
            case .success(let terminalResponse):
                if let terminalResponse = terminalResponse {
                    // There was actually an issue
                    if let output = terminalResponse.output {
                        MapleLogController.shared.local(log: "Injector installation output: \(output)")
                    }
                    if let error = terminalResponse.error {
                        MapleLogController.shared.local(log: "ERROR Injector installation error: \(error)")
                    }
                } else {
                    MapleLogController.shared.local(log: "Successfully installed Maple-LibInjector file")
                }
            }
        }
    }
    
    public func uninstallInjector() {
        
    }
    
    /// Restarts Maple-LibInjector if it is to crash for any reason
    @objc func injectorCrashHandler(notification: Notification) {
        MapleLogController.shared.local(log: "Maple's injector crashed... restarting")
        self.reloadMapleInjector()
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
                contents += " " + FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Application Support/Maple/Runnables/\(lib)"
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
                    listenFile[leaf.targetBundleID![i]]!.append("\(leaf.development ? "../Development/Runnables/" : "")\(leaf.leafID!)/\(leaf.libraryName!)")
                } else {
                    listenFile[leaf.targetBundleID![i]] = ["\(leaf.development ? "../Development/Runnables/" : "")\(leaf.leafID!)/\(leaf.libraryName!)"]
                }
            }
            
            if leaf.killOnInject {
                procs.append(contentsOf: leaf.targetBundleID!)
            }
        }
        
        // Write listen.txt file
        MapleFileHelper.shared.writeFile(withContents: self.listenContents(for: listenFile), atLocation: MapleController.listenFile)
        
        // Spin up an instance of Maple-LibInjector with above file
        self.startMapleInjector()
        
        // Kill the processes, optionally check if the user would like them to be restarted
        do {
            try self.killProcesses(withBIDs: procs)
        } catch {
            MapleLogController.shared.local(log: "ERROR Failed to begin injection \(error)")
        }
    }

    /// Stops all leaves from running
    public func stopInjectingEnabledLeaves() {
        self.stopMapleInjector()
        try? self.fManager.removeItem(at: MapleController.listenFile)
        
        var bids: [String] = []
        for leaf in self.runningLeaves {
            bids.append(contentsOf: leaf.targetBundleID!)
        }
        try? self.killProcesses(withBIDs: bids)
    }
    
    /// Starts up Maple-LibInjector with default listen file
    private func startMapleInjector() {
        if MaplePreferencesController.shared.sipProperlyDisabled && MaplePreferencesController.shared.injectionEnabled {
            let sema = DispatchSemaphore(value: 1)
            Task {
                do {
                    let response = try await self.xpcService.sendMessage([MapleController.listenFile], to: SharedConstants.mapleInjectionBeginInjection)
                    if response == nil {
                        MapleLogController.shared.local(log: "Successfully began injection")
                    } else {
                        MapleLogController.shared.local(log: "ERROR Errored while beginning injection: \(response!)")
                    }
                } catch {
                    MapleLogController.shared.local(log: "ERROR Failed to begin injection: \(error)")
                }
                sema.signal()
            }
            sema.wait()
            self.injecting = true
        } else {
            MapleLogController.shared.local(log: "ERROR SIP is not disabled, cannot begin Maple's injector")
        }
    }
    
    /// Stops Maple-LibInjector from injecting
    private func stopMapleInjector() {
        guard self.injecting == true else { return }
        let sema = DispatchSemaphore(value: 0)
        Task {
            do {
                let _ = try await self.xpcService.send(to: SharedConstants.mapleInjectionEndInjection)
                MapleLogController.shared.local(log: "Successfully ended injection")
            } catch {
                MapleLogController.shared.local(log: "ERROR Errored when ending injection: \(error)")
            }
            sema.signal()
        }
        sema.wait()
        self.injecting = false
    }
    
    /// Reloads Maple-LibInjector after changing a listen file
    public func reloadMapleInjector() {
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
                kp.arguments = ["-9", "\(running.processIdentifier)"]
                kp.launch()
                kp.waitUntilExit()
            }
        }
    }
    
    /// Kills a given process if it's currently running
    /// - Parameter bid: Bundle ID of a process you would like to kill
    func killProcess(withBID bid: String) throws {
        try self.killProcesses(withBIDs: [bid])
    }
    
    //MARK: Leaf Management
    
    /// Creates a Leaf object from a file
    /// If this is a development leaf, it will take care of installing it as well
    /// - Parameter file: URL of the file, wherever it is stored on disk
    /// - Returns: Optional Leaf object, if no errors are thrown
    func createLeaf(_ file: URL, fromDevelopment dev: Bool = false) throws -> Leaf? {
        let internalLoc: URL = dev ?
            MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("tmpInstallable.zip") :
            MapleController.installedDir.appendingPathComponent("tmpInstallable.zip")
        
        let unzippedPackageURL: URL = dev ?
            MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("installing") :
            MapleController.installedDir.appendingPathComponent("installing", isDirectory: true)
        
        defer {
            // Clean up!
            try? self.fManager.removeItem(at: internalLoc)
            try? self.fManager.removeItem(at: unzippedPackageURL)
            if dev {
                try? self.fManager.removeItem(at: file)
            }
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
        
        if dev {
            //TODO: Verify that this leaf has a secure signature
            //Right now, there is nothing stopping any other process from inputting a malicious leaf into this folder and having it install, need to prevent this using some sort of passphrase?
        }
        
        // Sap file is located at unzipped + folder-name + "info.sap"
        let sapRes: String? = MapleFileHelper.shared.readFile(atLocation: unzippedPackageURL.appendingPathComponent(containingFolder! + "/info.sap"))
        
        guard let _ = sapRes else { throw InstallError.invalidSap }
        
        let sapInfo: [String] = sapRes!.components(separatedBy: "\n")
        
        // Create a Leaf object
        let resultLeaf: Leaf = Leaf()
        
        // Process the .sap file to get all information about it
        for line in sapInfo {
            resultLeaf.add(field: line)
        }
        
        if resultLeaf.isValid() {
            //Move files to the hideen installing directory
            do {
                let destination = MapleController.hiddenInstallingDir.appendingPathComponent("installing.mapleleaf")
                if self.fManager.fileExists(atPath: destination.path) {
                    try? self.fManager.removeItem(at: destination)
                }
                try self.fManager.copyItem(at: internalLoc, to: destination)
            } catch {
                MapleLogController.shared.local(log: "ERROR Failed to copy the whole mapleleaf file to the installing directory")
                throw InstallError.fileCopyError
            }
            
            do {
                let destTwo = MapleController.hiddenInstallingDir.appendingPathComponent("library")
                if self.fManager.fileExists(atPath: destTwo.path) {
                    try? self.fManager.removeItem(at: destTwo)
                }
                try self.fManager.copyItem(at: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/\(resultLeaf.libraryName!)"), to: destTwo)
            } catch {
                // Could not copy dylib to runnables directory
                MapleLogController.shared.local(log: "ERROR Failed to copy library to installing directory: \(error.localizedDescription)")
                throw InstallError.fileCopyError
            }
            
            if self.fManager.fileExists(atPath: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/prefs.json").path) {
                // Should copy the preference file to the respective preferences folder
                let prefsDest = MapleController.hiddenInstallingDir.appendingPathComponent("prefs.json")
                if self.fManager.fileExists(atPath: prefsDest.path) {
                    try? self.fManager.removeItem(at: prefsDest)
                }
                do {
                    try self.fManager.copyItem(at: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/prefs.json"), to: prefsDest)
                } catch {
                    MapleLogController.shared.local(log: "ERROR Failed to copy the preferences to the installing directory")
                }
                resultLeaf.hasPreferences = true
            }
            
            if dev {
                if MaplePreferencesController.shared.developmentNotify {
                    MapleNotificationController.shared.sendLocalNotification(withTitle: "Development Leaf Detected", body: "We will now start injecting \(resultLeaf.name ?? "") onto your Mac")
                }
                
                resultLeaf.development = true
                resultLeaf.enabled = true
                
                do {
                    try MapleController.shared.installLeaf(resultLeaf)
                } catch {
                    MapleLogController.shared.local(log: "ERROR Failed to install the development leaf")
                }
            }
        } else {
            throw InstallError.invalidSap
        }
        
        // TODO: Create a script which can read into the dylib to parse which methods are hooked!
        return resultLeaf
    }
    
    /// Responsible for installing a Leaf
    /// Saves the files to proper locations and begins injection
    /// Adds to an observable list
    /// - Parameter leaf: Leaf object to install
    func installLeaf(_ leaf: Leaf) throws {
        guard leaf.isValid() else { throw InstallError.unknown }
        if self.installedLeaves.contains(where: { leaf.leafID == $0.leafID }) {
            if let alreadyLeaf = self.installedLeaves.first(where: {$0.leafID == leaf.leafID }) {
                
                self.uninstallLeaf(alreadyLeaf) // Yoink
            }
        }
        
        //Copy the files to where they should actually go
        do {
            let destination = (leaf.development ? MapleDevelopmentHelper.devInstalledFolderURL : MapleController.installedDir).appendingPathComponent("/\(leaf.leafID ?? "").mapleleaf")
            if self.fManager.fileExists(atPath: destination.path) {
                try? self.fManager.removeItem(at: destination)
            }
            try self.fManager.copyItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("installing.mapleleaf"), to: destination)
            try? self.fManager.removeItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("installing.mapleleaf"))
        } catch {
            throw InstallError.fileCopyError
        }
        
        do {
            let destTwo = (leaf.development ? MapleDevelopmentHelper.devRunnablesFolderURL : MapleController.runnablesDir).appendingPathComponent("/\(leaf.leafID!)/\(leaf.libraryName!)")
            try self.fManager.createDirectory(at: (leaf.development ? MapleDevelopmentHelper.devRunnablesFolderURL : MapleController.runnablesDir).appendingPathComponent("/\(leaf.leafID!)"), withIntermediateDirectories: true)
            if self.fManager.fileExists(atPath: destTwo.path) {
                try? self.fManager.removeItem(at: destTwo)
            }
            try self.fManager.copyItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("library"), to: destTwo)
            try? self.fManager.removeItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("library"))
        } catch {
            // Could not copy dylib to runnables directory
            MapleLogController.shared.local(log: "ERROR Failed to copy dylib to runnables directory: \(error.localizedDescription)")
            throw InstallError.fileCopyError
        }
        
        if self.fManager.fileExists(atPath: MapleController.hiddenInstallingDir.appendingPathComponent("prefs.json").path) {
            // Should copy the preference file to the respective preferences folder
            let prefsDest = (leaf.development ? MapleDevelopmentHelper.devPreferencesFolderURL : MapleController.preferencesDir).appendingPathComponent("\(leaf.leafID!).json")
            if self.fManager.fileExists(atPath: prefsDest.path) {
                try? self.fManager.removeItem(at: prefsDest)
            }
            do {
                try self.fManager.copyItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("prefs.json"), to: prefsDest)
            } catch {
                MapleLogController.shared.local(log: "ERROR Failed to copy the preferences to their proper location")
            }
            try? self.fManager.removeItem(at: MapleController.hiddenInstallingDir.appendingPathComponent("prefs.json"))
            leaf.hasPreferences = true
        }
        
        // Add this to the live list
        let sema = DispatchSemaphore(value: 1)
        DispatchQueue.main.async {
            self.installedLeaves.append(leaf)
            sema.signal()
        }
        sema.wait()
        if !leaf.development {
            self.updateLocallyStoredLeaves()
        }
        self.reloadInjection()
    }
    
    func uninstallLeaf(_ leaf: Leaf) {
        // Remove it from memory
        DispatchQueue.main.async {
            self.installedLeaves.removeAll(where: { $0.leafID == leaf.leafID })
            self.updateLocallyStoredLeaves()
        }
        
        try? self.killProcesses(withBIDs: leaf.targetBundleID!)
        
        if !leaf.development {
            do {
                // Remove the stored files
                try FileManager.default.removeItem(at: (leaf.development ? MapleDevelopmentHelper.devInstalledFolderURL : MapleController.installedDir).appendingPathComponent("\(leaf.leafID!).mapleleaf"))
                if leaf.hasPreferences {
                    try FileManager.default.removeItem(at: (leaf.development ? MapleDevelopmentHelper.devPreferencesFolderURL : MapleController.preferencesDir).appendingPathComponent("\(leaf.leafID!).json"))
                }
                try FileManager.default.removeItem(at: (leaf.development ? MapleDevelopmentHelper.devRunnablesFolderURL : MapleController.runnablesDir).appendingPathComponent("\(leaf.leafID!)/\(leaf.libraryName!)"))
                try FileManager.default.removeItem(at: (leaf.development ? MapleDevelopmentHelper.devRunnablesFolderURL : MapleController.runnablesDir).appendingPathComponent("\(leaf.leafID!)"))
            } catch {
                MapleLogController.shared.local(log: "ERROR Unable to delete files from installed leaves")
            }
            
            self.updateLocallyStoredLeaves()
        }
    }
    
    /// Save self.installedLeaves to UserDefaults
    func updateLocallyStoredLeaves() {
        let encodedData = try? JSONEncoder().encode(self.installedLeaves.filter({ !$0.development }))
        
        guard let _ = encodedData else { MapleLogController.shared.local(log: "ERROR Failed to update a local list of installed Leaves"); return }
        
        if encodedData!.isEmpty {
            MapleLogController.shared.local(log: "ERROR Failed to properly convert leaves to Data for storage")
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
    
    /// Open a window to view development and app logs
    public func openLogWindow() {
        self.installerWindow = NSWindow(contentViewController: NSHostingController(rootView: LogWindowView()))
        self.installerWindow?.setContentSize(NSSize(width: 600, height: 400))
        self.installerWindow?.title = "Maple Logs"
        self.installerWindow?.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        self.installerWindow?.minSize = NSSize(width: 600, height: 400)
        self.installerWindow?.contentMinSize = NSSize(width: 600, height: 400)
        
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        self.installerWindow?.makeKey()
        self.installerWindow?.orderFrontRegardless()
    }
    
    /// Close an open install window
    public func closeInstallWindow() {
        if self.installerWindow != nil {
            self.installerWindow!.close()
            self.installerWindow = nil
        }
    }
}
