//
//  HelperMonitor.swift
//  Maple
//
//  Created by Hallie on 5/16/22.
//

import Foundation
import EmbeddedPropertyList
import AppKit
import SecureXPC

/// Monitors the on disk location of the helper tool and its launchd property list.
/// Updates information on call of `determineStatus()`
class HelperToolMonitor: ObservableObject {
    /// Name of the privileged executable being monitored
    private let constants: SharedConstants
    
    @Published public var registeredWithLaunchd: Bool = false
    @Published public var registrationPlistExists: Bool = false
    @Published public var helperToolExists: Bool = false
    @Published public var helperToolBundleVersion: BundleVersion? = nil
    @Published public var connectionValid: Bool = false
    
    /// Creates the monitor.
    /// - Parameter constants: Constants defining needed file paths.
    init(constants: SharedConstants) {
        self.constants = constants
    }
    
    /// Determines the installation status of the helper tool
    /// - Returns: The status of the helper tool installation.
    func determineStatus() {
        // Registered with launchd
        let process = Process()
        process.launchPath = "/bin/launchctl"
        process.arguments = ["print", "system/\(constants.helperToolLabel)"]
        process.qualityOfService = QualityOfService.userInitiated
        process.standardOutput = nil
        process.standardError = nil
        process.launch()
        process.waitUntilExit()
        let regLaunchd = (process.terminationStatus == 0)
        
        // Registration property list exists on disk
        let plistExists = FileManager.default.fileExists(atPath: constants.blessedPropertyListLocation.path)
        
        let htbv: BundleVersion?
        let hte: Bool
        do {
            let infoPropertyList = try HelperToolInfoPropertyList(from: constants.blessedLocation)
            htbv = infoPropertyList.version
            hte = true
        } catch {
            htbv = nil
            hte = false
        }
        
        self.registeredWithLaunchd = regLaunchd
        self.registrationPlistExists = plistExists
        self.helperToolExists = hte
        self.helperToolBundleVersion = htbv
        
        guard let sharedConstants = (NSApplication.shared.delegate as? AppDelegate)?.sharedConstants else {
            fatalError("Should be able to get the app's sharedConstants")
        }
        
        let xpcService = XPCClient.forMachService(named: sharedConstants.machServiceName)
        
        xpcService.send(to: SharedConstants.mapleInjectionTestConnection) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    self.connectionValid = true
                case .failure(let error):
                    self.connectionValid = false
                    print("Failed to connect: \(error.localizedDescription)")
                }
            }
        }
    }
}
