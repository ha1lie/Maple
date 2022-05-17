//
//  InjectionError.swift
//  Maple
//
//  Created by Hallie on 5/13/22.
//

import Foundation

enum InjectionError: Error {
    case unableToTerminateProcess
    case unableToStartInjector
    case unableToCreateListenFile
    case injectionAlreadySpawned
    case injectionNotRunning
}

extension InjectionError: CustomStringConvertible {
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
