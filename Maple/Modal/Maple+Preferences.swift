//
//  Maple+Preferences.swift
//  Maple
//
//  Created by Hallie on 6/12/22.
//

import Foundation
import MapleKit

extension Preferences {
    
    private static var privateMapleAppPreferences: Preferences? = nil
    
    static var mapleAppPreferences: Preferences {
        if Preferences.privateMapleAppPreferences == nil {
            Preferences.privateMapleAppPreferences = Preferences(forBundle: MaplePreferencesController.mapleAppBundle)
                .withGroup { containerName in
                    PreferenceGroup(withName: "General", description: "General pickings and choosings", andIdentifier: "dev.halz.Maple.prefs.general", forContainer: containerName)
                        .withPreference { groupContainer in
                            Preference(withTitle: "Enable at Login", description: "Allow Maple to launch at login and enable your leaves without doing anything", withType: .bool, andIdentifier: MaplePreferencesController.launchAtLoginKey, forContainer: groupContainer) { newValue in
                                switch newValue {
                                case .bool(let boolVal):
                                    if let boolVal = boolVal {
                                        MaplePreferencesController.shared.launchAtLoginEnabled = boolVal
                                    }
                                default:
                                    ()
                                }
                            }
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Enable Injection", withType: .bool, andIdentifier: MaplePreferencesController.injectionEnabledKey, forContainer: groupContainer) { newValue in
                                switch newValue {
                                case .bool(let boolValue):
                                    if let boolValue = boolValue {
                                        MaplePreferencesController.shared.injectionEnabled = boolValue
                                    }
                                default:
                                    ()
                                }
                            }
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Development Mode", description: "When enabled, development mode is active, allowing for detailed logs, faster rebuilds, and a better more secure development experience", withType: .bool, andIdentifier: MaplePreferencesController.developmentKey, forContainer: groupContainer) { newValue in
                                switch newValue {
                                case .bool(let boolValue):
                                    if let boolValue = boolValue {
                                        MaplePreferencesController.shared.developmentEnabled = boolValue
                                    }
                                default:
                                    ()
                                }
                            }
                        }
                }.withGroup { containerName in
                    PreferenceGroup(withName: "Development", andIdentifier: "dev.halz.Maple.app.prefs.developmentgroup", forContainer: containerName, optionallyShownIfKeyIsTrue: MaplePreferencesController.developmentKey)
                        .withPreference { groupContainer in
                            Preference(withTitle: "Notify on install", description: "Maple will notify you when a development leaf is installed and begins injecting", withType: .bool, andIdentifier: MaplePreferencesController.developmentNotifyKey, forContainer: groupContainer) { newValue in
                                switch newValue {
                                case .bool(let boolValue):
                                    if let boolValue = boolValue {
                                        MaplePreferencesController.shared.developmentNotify = boolValue
                                    }
                                default:
                                    ()
                                }
                            }
                        }
                }
        }
        return Preferences.privateMapleAppPreferences!
    }
    
    static func fromLeaf(_ leaf: Leaf) -> Preferences? {
        guard let _ = leaf.leafID else { fatalError("Cannot gather preferences without a bundle identifier") }
        // Check for "BID".json in the preferences directory
        var prefsContainer: URL = MapleController.preferencesDir
        if leaf.development {
            prefsContainer = MapleDevelopmentHelper.devPreferencesFolderURL
        }
        
        let prefsURL = prefsContainer.appendingPathComponent(leaf.leafID! + ".json")
        if FileManager.default.fileExists(atPath: prefsURL.path) {
            // The preference file has been found
            if let prefData = try? Data(contentsOf: prefsURL) {
                return try? JSONDecoder().decode(Preferences.self, from: prefData)
            }
        }
        return nil
    }
}
