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
        let _ = try MapleController.shared.installFile(file, fromDevelopment: true)
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
