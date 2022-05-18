//
//  InjectionError.swift
//  Maple
//
//  Created by Hallie on 5/13/22.
//

import Foundation

enum InjectionError: Error, CustomStringConvertible {
    /// A currently running process is unable to be terminated programmatically
    case unableToTerminateProcess
    /// Helper tool is unable to start the injector
    case unableToStartInjector
    /// Unable to write the listen file for the injector
    case unableToCreateListenFile
    /// Injection cannot be restarted as it is already live
    case injectionAlreadySpawned
    /// Maple injector is not alive
    case injectionNotRunning
    
    public var description: String {
        switch self {
        case .unableToTerminateProcess:
            return "Unable to terminate a process"
        case .unableToStartInjector:
            return "Unable to create injector process"
        case .unableToCreateListenFile:
            return "Failed to create listen file"
        case .injectionAlreadySpawned:
            return "You are not permitted to spawn more than one injection process"
        case .injectionNotRunning:
            return "An injection process is not currently running"
        }
    }
}
