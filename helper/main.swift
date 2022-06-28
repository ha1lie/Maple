//
//  main.swift
//  helper
//
//  Created by Hallie on 5/4/22.
//

import Foundation
import SecureXPC

NSLog("starting helper tool. PID \(getpid()). PPID \(getppid()).")
NSLog("version: \(try HelperToolInfoPropertyList.main().version.rawValue)")

// Command line arguments were provided, so process them
if CommandLine.arguments.count > 1 {
    // Remove the first argument, which represents the name (typically the full path) of this helper tool
    var arguments = CommandLine.arguments
    _ = arguments.removeFirst()
    NSLog("run with arguments: \(arguments)")
    
    if let firstArgument = arguments.first {
        if firstArgument == Uninstaller.commandLineArgument {
            try Uninstaller.uninstallFromCommandLine(withArguments: arguments)
        } else {
            NSLog("argument not recognized: \(firstArgument)")
        }
    }
} else if getppid() == 1 { // Otherwise if started by launchd, start up XPC server
    NSLog("parent is launchd, starting up XPC server")
    let server = try XPCServer.forThisBlessedHelperTool()
    
    server.registerRoute(SharedConstants.uninstallRoute, handler: Uninstaller.uninstallFromXPC)
    server.registerRoute(SharedConstants.updateRoute, handler: Updater.updateHelperTool(atPath:))
    
    server.registerRoute(SharedConstants.mapleInjectionTestConnection, handler: MapleInjectionHelper.testConnection)
    
    server.registerRoute(SharedConstants.mapleInjectionBeginInjection, handler: MapleInjectionHelper.beginInjection(withFiles:))
    server.registerRoute(SharedConstants.mapleInjectionEndInjection, handler: MapleInjectionHelper.endInjection)
    
    server.setErrorHandler { error in
        if case .connectionInvalid = error {
            // Ignore invalidated connections as this happens whenever the client disconnects which is not a problem
        } else {
            NSLog("error: \(error)")
        }
    }
    server.startAndBlock()
} else { // Otherwise started via command line without arguments, print out help info
    print("Usage: \(try CodeInfo.currentCodeLocation().lastPathComponent) <command>")
    print("\nCommands:")
    print("\t\(Uninstaller.commandLineArgument)\tUnloads and deletes from disk this helper tool and configuration.")
}
