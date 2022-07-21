//
//  MaplePreferencesController.swift
//  Maple
//
//  Created by Hallie on 5/26/22.
//

import Foundation
import SecureXPC
import MapleKit
import LaunchAtLogin

class MaplePreferencesController: ObservableObject {
    
    static let shared: MaplePreferencesController = MaplePreferencesController()
    
    public static let mapleAppBundle: String = "dev.halz.Maple.app"
    
    //MARK: Preference Keys
    public static let injectionEnabledKey: String = "dev.halz.Maple.prefs.injectionEnabled"
    public static let launchAtLoginKey: String =  "dev.halz.Maple.prefs.launchAtLogin"
    public static let developmentKey: String = "dev.halz.Maple.prefs.development"
    public static let developmentNotifyKey: String = "dev.halz.Maple.prefs.development.notifyOnInstall"
    
    private static let completedWelcomeKey: String = "dev.halz.Maple.prefs.completedWelcome"
    
    @Published var openedPanel: Int? = nil
    @Published var openedLeafIndex: Int? = nil
    
    public var hasCompletedWelcome: Bool {
        return UserDefaults(suiteName: "dev.halz.Maple.app")?.bool(forKey: MaplePreferencesController.completedWelcomeKey) ?? false
    }
    
    private var authenticatedRootSIPDisabled: Bool {
        get {
            // Check if sip is disabled
            let sipNormal = Process()
            let normalPipe = Pipe()
            
            sipNormal.standardOutput = normalPipe
            sipNormal.standardError = normalPipe
            sipNormal.arguments = ["-c", "csrutil authenticated-root status"]
            sipNormal.launchPath = "/bin/zsh"
            sipNormal.standardInput = nil
            sipNormal.launch()
            
            let data = normalPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)!
            
            return output.contains("disabled")
        }
    }
    
    public var sipProperlyDisabled: Bool {
        get {
            // Check if sip is disabled
            let sipNormal = Process()
            let normalPipe = Pipe()
            
            sipNormal.standardOutput = normalPipe
            sipNormal.standardError = normalPipe
            sipNormal.arguments = ["-c", "csrutil status"]
            sipNormal.launchPath = "/bin/zsh"
            sipNormal.standardInput = nil
            sipNormal.launch()
            
            let data = normalPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)!
            
            return output.contains("disabled") && self.authenticatedRootSIPDisabled
        }
    }
    
    /// Checks if development mode is enabled with app
    @Published var developmentEnabled: Bool {
        didSet {
            if self.developmentEnabled {
                MapleDevelopmentHelper.shared.configure()
            } else {
                MapleDevelopmentHelper.shared.disconfigure()
            }
        }
    }
    
    /// Checks if the app should launch when user logs in
    @Published var launchAtLoginEnabled: Bool {
        didSet {
            if self.launchAtLoginEnabled {
                LaunchAtLogin.isEnabled = true
            } else {
                LaunchAtLogin.isEnabled = false
            }
        }
    }
    
    /// Checks if app should actually inject code into processes
    @Published var injectionEnabled: Bool {
        didSet {
            MapleController.shared.reloadInjection()
        }
    }
    
    /// Checks if app should notify when beginning to inject a development leaf
    @Published var developmentNotify: Bool
    
    init() {
        var prefVal = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.developmentKey)
        switch prefVal {
        case .bool(let boolVal):
            self.developmentEnabled = boolVal ?? false
        default:
            self.developmentEnabled = false
        }
        
        self.launchAtLoginEnabled = LaunchAtLogin.isEnabled
        Preferences.saveValue(.bool(LaunchAtLogin.isEnabled), withKey: MaplePreferencesController.launchAtLoginKey, toContainer: MaplePreferencesController.mapleAppBundle)
        
        prefVal = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.injectionEnabledKey)
        switch prefVal {
        case .bool(let boolVal):
            self.injectionEnabled = boolVal ?? false
        default:
            self.injectionEnabled = false
        }
        
        prefVal = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.developmentNotifyKey)
        switch prefVal {
        case .bool(let boolVal):
            self.developmentNotify = boolVal ?? false
        default:
            self.developmentNotify = false
        }
    }
    
    /// Mark Maple's system as complete
    public func completeWelcome(_ toVal: Bool = true) {
        UserDefaults(suiteName: MaplePreferencesController.mapleAppBundle)?.set(toVal, forKey: MaplePreferencesController.completedWelcomeKey)
    }
}
