//
//  InjectionError.swift
//  Maple
//
//  Created by Hallie on 4/16/22.
//

import Foundation

enum InjectionError: Error {
    case unableToTerminateProcess
    case unableToStartInjector
    case unableToCreateListenFile
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
        }
    }
}
