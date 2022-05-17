//
//  TerminalResponse.swift
//  Maple
//
//  Created by Hallie on 5/13/22.
//

import Foundation

/// Information produced by running a terminal command
struct TerminalResponse: Codable, CustomStringConvertible {
    /// Response code emitted by the process
    let exitCode: Int
    // The below are one or another
    let output: String?
    let error: String?
    
    var description: String {
        get {
            return "TerminalResponse(exitCode: \(self.exitCode), output: \(self.output ?? "None"), error: \(self.error ?? "None"))"
        }
    }
}
