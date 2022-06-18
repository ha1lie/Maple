//
//  MaplePreferencesController.swift
//  Maple
//
//  Created by Hallie on 5/26/22.
//

import Foundation
import SecureXPC
import MaplePreferences

class MaplePreferencesController: ObservableObject {
    
    static let shared: MaplePreferencesController = MaplePreferencesController()
    
    static let maplePreferences: Preferences = .mapleAppPreferences
    
    public static let mapleAppBundle: String = "dev.halz.Maple.app"
    
    public static let injectionEnabledKey: String = "dev.halz.Maple.prefs.injectionEnabled"
    public static let launchAtLoginKey: String =  "dev.halz.Maple.prefs.launchAtLogin"
    
    public static let developmentKey: String = "dev.halz.Maple.prefs.development"
    
    public static let developmentNotifyKey: String = "dev.halz.Maple.prefs.development.notifyOnInstall"
    
    @Published var developmentEnabled: Bool {
        didSet {
            if self.developmentEnabled {
                MapleDevelopmentHelper.shared.configure()
            } else {
                MapleDevelopmentHelper.shared.disconfigure()
            }
        }
    }
    
    @Published var launchAtLoginEnabled: Bool {
        didSet {
            if self.launchAtLoginEnabled {
                print("Enable launch at login")
            } else {
                print("Disable launch at login")
            }
        }
    }
    
    @Published var injectionEnabled: Bool {
        didSet {
            MapleController.shared.reloadInjection()
        }
    }
    
    /// Checks if app should notify when beginning to inject a development leaf
    @Published var developmentNotify: Bool
    
    init() {
        self.developmentEnabled = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.developmentKey) ?? false
        self.launchAtLoginEnabled = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.launchAtLoginKey) ?? false
        self.injectionEnabled = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.injectionEnabledKey) ?? false
        self.developmentNotify = Preferences.mapleAppPreferences.valueForKey(MaplePreferencesController.developmentNotifyKey) ?? false
    }
}
