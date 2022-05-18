//
//  MapleInjectionHelper.swift
//  helper
//
//  Created by Hallie on 5/12/22.
//

import Foundation
import AppKit

struct MapleInjectionHelper {
    
    static private var injectionProcess: Process? = nil
    static private var outputPipe: Pipe? = nil
    static private var errorPipe: Pipe? = nil
    
    static func testConnection() -> Bool {
        return true
    }
    
    static func beginInjection() -> TerminalResponse? {
        if MapleInjectionHelper.injectionProcess != nil { let _ = MapleInjectionHelper.endInjection() } // Ensure no one is doing any double dipping
        
        MapleInjectionHelper.injectionProcess = Process()
        
        if MapleInjectionHelper.outputPipe == nil { MapleInjectionHelper.outputPipe = Pipe() }
        if MapleInjectionHelper.errorPipe == nil { MapleInjectionHelper.errorPipe = Pipe() }
        
        MapleInjectionHelper.injectionProcess!.launchPath = SharedConstants.injectorFileString
        MapleInjectionHelper.injectionProcess!.arguments = [SharedConstants.listenFileString]
        MapleInjectionHelper.injectionProcess!.qualityOfService = QualityOfService.userInitiated
        MapleInjectionHelper.injectionProcess!.standardOutput = MapleInjectionHelper.outputPipe!
        MapleInjectionHelper.injectionProcess!.standardError = MapleInjectionHelper.errorPipe!
        try? MapleInjectionHelper.injectionProcess!.run()
        
        if MapleInjectionHelper.injectionProcess!.isRunning {
            return nil
        } else {
            return TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess!.terminationStatus), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
        }
    }
    
    static func endInjection() -> TerminalResponse? {
        guard let _ = MapleInjectionHelper.injectionProcess else { return TerminalResponse(exitCode: -1, output: nil, error: "Injection process not running") } // Ensure you're not trying to stop a non-existant process
        
        MapleInjectionHelper.injectionProcess?.terminate()
        MapleInjectionHelper.injectionProcess = nil
        MapleInjectionHelper.outputPipe = nil
        MapleInjectionHelper.errorPipe = nil
//        let res = TerminalResponse(exitCode: Int(MapleInjectionHelper.injectionProcess?.terminationStatus ?? 0), output: String(data: MapleInjectionHelper.outputPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8), error: String(data: MapleInjectionHelper.errorPipe?.fileHandleForReading.availableData ?? Data(), encoding: .utf8))
        
        
        
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
