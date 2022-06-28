//
//  MapleInjectionHelper.swift
//  helper
//
//  Created by Hallie on 5/12/22.
//

import Foundation
import AppKit
import MaplePreferences

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
    
    /// Begin the helper's injection process
    /// - Returns: TerminalResponse if there is an issue starting up the process
    static func beginInjection(withFiles files: [URL]) -> TerminalResponse? {
        guard files.count == 2 else { fatalError("Incorrect number of file locations provided to begin injection") }
        
        if MapleInjectionHelper.injectionProcess != nil { let _ = MapleInjectionHelper.endInjection() } // Ensure no one is doing any double dipping
        
        MapleInjectionHelper.injectionProcess = Process()
        
        if MapleInjectionHelper.outputPipe == nil { MapleInjectionHelper.outputPipe = Pipe() }
        if MapleInjectionHelper.errorPipe == nil { MapleInjectionHelper.errorPipe = Pipe() }
        
        MapleInjectionHelper.injectionProcess!.launchPath = files[0].path
        MapleInjectionHelper.injectionProcess!.arguments = [files[1].path]
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
