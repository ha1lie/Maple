//
//  MapleInjectionHelper.swift
//  helper
//
//  Created by Hallie on 5/12/22.
//

import Foundation
import AppKit
import MapleKit

/// Helper class to run injection-focused functions
struct MapleInjectionHelper {
    static private var injectionProcess: Process? = nil
    static private var outputPipe: Pipe? = nil
    static private var errorPipe: Pipe? = nil
    static private var purposelyEnded: Bool = false
    /// Test if the helper tool is able to communicate with the main app
    /// - Returns: True
    static func testConnection() -> Bool {
        return true
    }
    
    /// Uninstalls all of the root files so that it is safe to turn SIP back on
    static func uninstallInjector() {
        let rm = Process()
        rm.launchPath = "/usr/bin/sudo"
        rm.arguments = ["rm", "-rf", "/Library/Maple"]
        try? rm.run()
        rm.waitUntilExit()
    }
    
    /// Installs the injection binary for Maple
    /// - Returns: Optional TerminalResponse object with any pertinent information
    static func installInjector() -> TerminalResponse? {
        if let containingFolder: URL = URL(string: "/Library/Maple") {
            if !FileManager.default.fileExists(atPath: containingFolder.path) {
                let mkdir = Process()
                mkdir.launchPath = "/usr/bin/sudo"
                mkdir.arguments = ["mkdir", "/Library/Maple"]
                try? mkdir.run()
            }
            
            if let injectorURL = SharedConstants.injectorLocation {
                if !FileManager.default.fileExists(atPath: injectorURL.path) {
                    let curl = Process()
                    curl.launchPath = "/usr/bin/sudo"
                    curl.arguments = ["curl", "-L", "-o", injectorURL.path, "https://github.com/ha1lie/Maple-LibInjector/releases/download/v1.0/Maple-LibInjector"]
                    do {
                        try curl.run()
                    } catch {
                        return TerminalResponse(exitCode: -1, output: nil, error: "ERROR Threw error while running curl \(error.localizedDescription)")
                    }
                    
                    curl.waitUntilExit()
                    
                    let chmod = Process()
                    chmod.launchPath = "/usr/bin/sudo"
                    chmod.arguments = ["chmod", "+x", injectorURL.path]
                    do {
                        try chmod.run()
                    } catch {
                        return TerminalResponse(exitCode: -1, output: nil, error: "ERROR Threw error while running chmod \(error.localizedDescription)")
                    }
                }
            } else {
                return TerminalResponse(exitCode: -1, output: nil, error: "ERROR Failed to create the injector location URL")
            }
        } else {
            return TerminalResponse(exitCode: -1, output: nil, error: "ERROR Failed to create the root Maple folder")
        }
        return nil
    }
    
    /// Begin the helper's injection process
    /// - Returns: TerminalResponse if there is an issue starting up the process
    static func beginInjection(withFiles files: [URL]) -> TerminalResponse? {
        guard files.count == 1 else { fatalError("Incorrect number of file locations provided to begin injection") }
        guard SharedConstants.injectorLocation != nil else { return TerminalResponse(exitCode: -1, output: nil, error: "ERROR Could not resolve injector location") }
        
        if MapleInjectionHelper.injectionProcess != nil { let _ = MapleInjectionHelper.endInjection() } // Ensure no one is doing any double dipping
        
        if !FileManager.default.fileExists(atPath: SharedConstants.injectorLocation!.path) {
            if let response = self.installInjector() {
                return response
            }
        }
        
        MapleInjectionHelper.injectionProcess = Process()
        
        if MapleInjectionHelper.outputPipe == nil { MapleInjectionHelper.outputPipe = Pipe() }
        if MapleInjectionHelper.errorPipe == nil { MapleInjectionHelper.errorPipe = Pipe() }
        
        MapleInjectionHelper.injectionProcess!.launchPath = SharedConstants.injectorLocation?.path
        MapleInjectionHelper.injectionProcess!.arguments = [files[0].path]
        MapleInjectionHelper.injectionProcess!.qualityOfService = QualityOfService.userInitiated
        MapleInjectionHelper.injectionProcess!.standardOutput = MapleInjectionHelper.outputPipe!
        MapleInjectionHelper.injectionProcess!.standardError = MapleInjectionHelper.errorPipe!
        MapleInjectionHelper.purposelyEnded = false
        MapleInjectionHelper.injectionProcess?.terminationHandler = { proc in
            if !MapleInjectionHelper.purposelyEnded {
                DistributedNotificationCenter.default().post(name: Notification.Name("maple.injector.crash"), object: nil)
            }
        }
        try? MapleInjectionHelper.injectionProcess!.run()
        
        if MapleInjectionHelper.injectionProcess!.isRunning {
            return nil
        } else {
            return TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess!.terminationStatus), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
        }
    }
    
    /// Ends the injection process
    /// - Returns: TerminalResponse with appropriate output from the process
    static func endInjection() -> TerminalResponse? {
        guard let _ = MapleInjectionHelper.injectionProcess else { return TerminalResponse(exitCode: -1, output: nil, error: "Injection process not running") } // Ensure you're not trying to stop a non-existant process
        MapleInjectionHelper.purposelyEnded = true
        MapleInjectionHelper.injectionProcess?.terminate()
        
        let res = TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess?.terminationStatus ?? 0), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
        
        MapleInjectionHelper.injectionProcess = nil
        MapleInjectionHelper.outputPipe = nil
        MapleInjectionHelper.errorPipe = nil
        
        return res
    }
}
