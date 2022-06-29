//
//  MapleDevelopmentHelper.swift
//  Maple
//
//  Created by Hallie on 5/25/22.
//

import Foundation
import Zip
import MaplePreferences

class MapleDevelopmentHelper: ObservableObject {
    static let shared: MapleDevelopmentHelper = MapleDevelopmentHelper()
    
    static let devFolderURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Development", isDirectory: true)
    static let devRunnablesFolderURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Development/Runnables", isDirectory: true)
    static let devPreferencesFolderURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Development/Preferences", isDirectory: true)
    static let devInstalledFolderURL: URL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/Maple/Development/Installed", isDirectory: true)
    
    static let devFolderString: String = FileManager.default.homeDirectoryForCurrentUser.path + "/Library/Application Support/Maple/Development"
    
    private var developmentMonitor: DevelopmentMonitor? = nil
    
    public func configure() {
        if let _ = self.developmentMonitor {
            self.disconfigure()
        }
        
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devInstalledFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devPreferencesFolderURL, withIntermediateDirectories: true)
        
        if MapleDevelopmentHelper.devFolderString == "/Users/hallie/Library/Application Support/Maple/Development" {
            print("Heyyo it got the right folder with it and everything")
        } else {
            print("Dev controller failed to actually make the right thing... hmm")
            print(MapleDevelopmentHelper.devFolderString)
        }
        
        self.developmentMonitor = DevelopmentMonitor()
        self.developmentMonitor?.startMonitoring()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(valueRequestHandler(notification:)), name: NSNotification.Name("maple.valueRequest"), object: nil)
    }
    
    @objc private func valueRequestHandler(notification: Notification) {
        if let request = notification.object as? String {
            let pieces = request.components(separatedBy: "::")
            if pieces.count == 2 {
                if let value = Preferences.valueForKey(pieces[0], inContainer: pieces[1]) {
                    DistributedNotificationCenter.default().post(name: Notification.Name("maple.valueRequestResponse"), object: value.toString())
                }
            }
        }
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
        let _ = try MapleController.shared.createLeaf(file, fromDevelopment: true)
    }
    
    public func uninstallDevLeaf(_ leaf: Leaf) {
        MapleController.shared.stopInjectingEnabledLeaves()
        MapleController.shared.uninstallLeaf(leaf)
        do {
            try FileManager.default.removeItem(at: MapleDevelopmentHelper.devInstalledFolderURL.appendingPathComponent("\(leaf.leafID!).mapleleaf"))
            try FileManager.default.removeItem(at: MapleDevelopmentHelper.devRunnablesFolderURL.appendingPathComponent("\(leaf.leafID!)/\(leaf.libraryName!)"))
        } catch {
            MapleLogController.shared.local(log: "WARNING Unable to delete files from installed dev leaf")
        }
    }
}
