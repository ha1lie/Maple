//
//  MapleDevelopmentHelper.swift
//  Maple
//
//  Created by Hallie on 5/25/22.
//

import Foundation
import Zip

class MapleDevelopmentHelper: ObservableObject {
    static let shared: MapleDevelopmentHelper = MapleDevelopmentHelper()
    
    static let devFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development", isDirectory: true)
    static let devRunnablesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Runnables")
    static let devPreferencesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Preferences")
    static let devInstalledFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Installed")
    
    static let devFolderString: String = "/Users/hallie/Library/Application Support/Maple/Development"
    
    private var developmentMonitor: DevelopmentMonitor? = nil
    
    @Published var injectingDevelopmentLeaf: String? = nil
    
    public func configure() {
        if let _ = self.developmentMonitor {
            self.disconfigure()
        }
        
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devInstalledFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devPreferencesFolderURL, withIntermediateDirectories: true)
        
        self.developmentMonitor = DevelopmentMonitor()
        self.developmentMonitor?.startMonitoring()
    }
    
    public func disconfigure() {
        guard let _ = self.developmentMonitor else { return }
        self.developmentMonitor?.stop()
        self.developmentMonitor = nil
        
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devRunnablesFolderURL)
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devInstalledFolderURL)
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devPreferencesFolderURL)
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devFolderURL)
    }
    
    public func installDevLeaf(_ file: URL) throws {
        let internalLoc: URL = MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("tmpInstallable.zip")
        let unzippedPackageURL: URL = MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("installing", isDirectory: true)
        
        defer {
            // Clean up!
            try? FileManager.default.removeItem(at: internalLoc)
            try? FileManager.default.removeItem(at: unzippedPackageURL)
            try? FileManager.default.removeItem(at: file)
        }
        
        do {
            try FileManager.default.copyItem(at: file , to: internalLoc)
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
        
        //TODO: NEED TO VERIFY THIS IS A SECURE LEAF TO USE AS DEVELOPMENT TO PREVENT OTHERS FROM WRITING HERE
        
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
            
            //Now we have resultLeaf
            MapleNotificationController.shared.sendLocalNotification(withTitle: "Development Leaf Detected", body: "We will now start injecting \(resultLeaf.name ?? "") onto your machine")
            
            DispatchQueue.main.async {
                self.injectingDevelopmentLeaf = resultLeaf.name
            }
            //TODO: Make this actually begin injection
            resultLeaf.development = true
            resultLeaf.enabled = true
            
            do {
                try MapleController.shared.installLeaf(resultLeaf)
            } catch {
                print("Failed to install the development leaf")
            }
            
            // Copy the files in
            
            do {
                try FileManager.default.copyItem(at: internalLoc, to: MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("\(resultLeaf.leafID ?? "").mapleleaf"))
            } catch {
                print("Couldn't remove the installed mapleleaf")
                throw InstallError.fileCopyError
            }
            
            do {
                try FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("/\(resultLeaf.leafID!)"), withIntermediateDirectories: true)
                try FileManager.default.copyItem(at: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/\(resultLeaf.libraryName!)"), to: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("/\(resultLeaf.leafID!)/\(resultLeaf.libraryName!)"))
            } catch {
                // Could not copy dylib to runnables directory
                print("Failed to copy dylib to runnables directory: \(error.localizedDescription)")
                throw InstallError.fileCopyError
            }
        } else {
            print("This is the invalid leaf: \(resultLeaf)")
            throw InstallError.invalidSap
        }
    }
    
    public func uninstallDevLeaf(_ leaf: Leaf) {
        MapleController.shared.stopInjectingEnabledLeaves()
        MapleController.shared.uninstallLeaf(leaf)
        do {
            try FileManager.default.removeItem(at: MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("\(leaf.leafID!).mapleleaf"))
            try FileManager.default.removeItem(at: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("\(leaf.leafID!)/\(leaf.libraryName!)"))
        } catch {
            print("Unable to delete files from installed dev leaf")
        }
    }
}
