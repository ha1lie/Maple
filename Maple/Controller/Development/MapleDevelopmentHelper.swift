//
//  MapleDevelopmentHelper.swift
//  Maple
//
//  Created by Hallie on 5/25/22.
//

import Foundation
import Zip

class MapleDevelopmentHelper {
    static let shared: MapleDevelopmentHelper = MapleDevelopmentHelper()
    
    static let devFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development", isDirectory: true)
    static let devRunnablesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Runnables")
    static let devPreferencesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Preferences")
    static let devInstalledFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Installed")
    
    static let devFolderString: String = "/Users/hallie/Library/Application Support/Maple/Development"
    
    private var developmentMonitor: DevelopmentMonitor? = nil
    
    public func configure() {
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devInstalledFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devPreferencesFolderURL, withIntermediateDirectories: true)
        
        if let _ = self.developmentMonitor {
            self.disconfigure()
        }
        self.developmentMonitor = DevelopmentMonitor()
        self.developmentMonitor?.startMonitoring()
    }
    
    public func disconfigure() {
        self.developmentMonitor?.stop()
        self.developmentMonitor = nil
        
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devRunnablesFolderURL)
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devInstalledFolderURL)
        try? FileManager.default.removeItem(at: MapleDevelopmentHelper.devPreferencesFolderURL)
    }
    
    public func installDevLeaf(_ file: URL) throws {
        let internalLoc: URL = MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("tmpInstallable.zip")
        let unzippedPackageURL: URL = MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("installing", isDirectory: true)
        
        defer {
            // Clean up!
            try? FileManager.default.removeItem(at: internalLoc)
            try? FileManager.default.removeItem(at: unzippedPackageURL)
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
        let resultLeaf: Leaf? = Leaf()
        
        // Process the .sap file to get all information about it
        for line in sapInfo {
            try resultLeaf?.add(field: line)
        }
        
        if resultLeaf?.isValid() ?? false {
            do {
                try FileManager.default.copyItem(at: internalLoc, to: MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("/\(resultLeaf!.leafID ?? "").mapleleaf"))
            } catch {
                print("Could not copy to installed directory")
            }
            
            do {
                try FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("/\(resultLeaf!.leafID!)"), withIntermediateDirectories: true)
                try FileManager.default.copyItem(at: unzippedPackageURL.appendingPathComponent("\(containingFolder!)/\(resultLeaf!.libraryName!)"), to: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("/\(resultLeaf!.leafID!)/\(resultLeaf!.libraryName!)"))
            } catch {
                // Could not copy dylib to runnables directory
                print("Failed to copy dylib to runnables directory: \(error.localizedDescription)")
            }
        }
        
        //Now we have resultLeaf
        
    }
}
