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
    
    static let devFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development", isDirectory: true)
    static let devRunnablesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Runnables")
    static let devPreferencesFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Preferences")
    static let devInstalledFolderURL: URL = URL(fileURLWithPath: "/Users/hallie/Library/Application Support/Maple/Development/Installed")
    
    static let devFolderString: String = "/Users/hallie/Library/Application Support/Maple/Development"
    
    private var developmentMonitor: DevelopmentMonitor? = nil
    
    public func configure() {
        if let _ = self.developmentMonitor {
            self.disconfigure()
        }
        
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devRunnablesFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devInstalledFolderURL, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: MapleDevelopmentHelper.devPreferencesFolderURL, withIntermediateDirectories: true)
        
        self.developmentMonitor = DevelopmentMonitor()
        self.developmentMonitor?.startMonitoring()
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(logObserver(notification:)), name: NSNotification.Name(rawValue: "maple.log"), object: nil)
        
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(valueRequestHandler(notification:)), name: NSNotification.Name("maple.valueRequest"), object: nil)
    }
    
    @objc private func valueRequestHandler(notification: Notification) {
        print("Got a preference value request")
        if let request = notification.object as? String {
            let pieces = request.components(separatedBy: "::")
            if pieces.count == 2 {
                if let value = Preferences.valueForKey(pieces[0], inContainer: pieces[1]) {
                    print("Is sending a response!")
                    DistributedNotificationCenter.default().post(name: Notification.Name("maple.valueRequestResponse"), object: value.toString())
                }
            }
        }
    }
    
    @objc private func logObserver(notification: Notification) {
        if let stuff = notification.object as? String {
            let parts = stuff.components(separatedBy: "+++")
            if parts.count == 2 {
                print("[\(parts[0])] - \(parts[1])")
            } else {
                print("Log with wrong number of parts")
            }
        } else {
            print("Notification object can't be string")
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
