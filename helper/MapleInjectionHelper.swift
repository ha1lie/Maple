//
//  MapleInjectionHelper.swift
//  helper
//
//  Created by Hallie on 5/12/22.
//

import Foundation

enum MapleInjectionHelper {
    
    static private var injectionProcess: Process? = nil
    static private var outputPipe: Pipe? = nil
    static private var errorPipe: Pipe? = nil
    
    static func testConnection() -> Bool {
        
        return true
    }
    
    static func beginInjection() -> TerminalResponse? {
        
        let myAppleScript = "display notification \"Lorem ipsum dolor sit amet\" with title \"Title\""
        let script = NSAppleScript(source: myAppleScript)
        script?.executeAndReturnError(nil)
        
        if self.injectionProcess != nil { let _ = MapleInjectionHelper.endInjection() } // Ensure no one is doing any double dipping
        
        if MapleInjectionHelper.outputPipe == nil { MapleInjectionHelper.outputPipe = Pipe() }
        if MapleInjectionHelper.errorPipe == nil { MapleInjectionHelper.errorPipe = Pipe() }
        
        MapleInjectionHelper.injectionProcess = Process()
        MapleInjectionHelper.injectionProcess!.launchPath = SharedConstants.injectorFileString
        MapleInjectionHelper.injectionProcess!.arguments = [SharedConstants.listenFileString]
        MapleInjectionHelper.injectionProcess!.standardOutput = MapleInjectionHelper.outputPipe
        MapleInjectionHelper.injectionProcess!.standardError = MapleInjectionHelper.errorPipe
        
        do {
            try self.injectionProcess?.run()
        } catch {
            let r = TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess?.terminationStatus ?? -1), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
            MapleInjectionHelper.outputPipe = nil
            MapleInjectionHelper.errorPipe = nil
            return r
        }
        
        return nil
    }
    
    static func endInjection() -> TerminalResponse? {
        guard let _ = MapleInjectionHelper.injectionProcess else { return nil } // Ensure you're not trying to stop a non-existant process
        
        if MapleInjectionHelper.injectionProcess!.isRunning {
            MapleInjectionHelper.injectionProcess!.terminate()
            
            let r = TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess?.terminationStatus ?? -1), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
            MapleInjectionHelper.outputPipe = nil
            MapleInjectionHelper.errorPipe = nil
            return r
        }
        
        return nil
    }
    
    static private func run(command: String, arguments: [String]) -> TerminalResponse? {
        let process = Process()
        process.launchPath = command
        process.arguments = arguments
        process.qualityOfService = QualityOfService.userInitiated
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        let errorPipe = Pipe()
        process.standardError = errorPipe
        process.launch()
        process.waitUntilExit()
        
        // Process and return response
        let terminationStatus = Int(process.terminationStatus)
        var standardOutput: String?
        var standardError: String?
        if let output = String(data: outputPipe.fileHandleForReading.availableData,
                               encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           output.count != 0 {
            standardOutput = output
        }
        if let error = String(data: errorPipe.fileHandleForReading.availableData,
                              encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
           error.count != 0 {
            standardError = error
        }
        outputPipe.fileHandleForReading.closeFile()
        errorPipe.fileHandleForReading.closeFile()
        
        return TerminalResponse(exitCode: terminationStatus, output: standardOutput, error: standardError)
    }
}
