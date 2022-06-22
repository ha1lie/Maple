//
//  Maple+Preferences.swift
//  Maple
//
//  Created by Hallie on 6/12/22.
//

import Foundation
import MaplePreferences

extension Preferences {
    
    private static var privateMapleAppPreferences: Preferences? = nil
    
    static var mapleAppPreferences: Preferences {
        if Preferences.privateMapleAppPreferences == nil {
            Preferences.privateMapleAppPreferences = Preferences(forBundle: MaplePreferencesController.mapleAppBundle)
                .withGroup { containerName in
                    PreferenceGroup(withName: "General", description: "General pickings and choosings", andIdentifier: "dev.halz.Maple.prefs.general", forContainer: containerName)
                        .withPreference { groupContainer in
                            Preference(withTitle: "Enable at Login", description: "**DNW** Allow Maple to launch at login and enable your leaves without doing anything", withType: .bool, andIdentifier: MaplePreferencesController.launchAtLoginKey, forContainer: groupContainer) { newValue in
                                if let newValue = newValue as? Bool {
                                    MaplePreferencesController.shared.launchAtLoginEnabled = newValue
                                }
                            }
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Enable Injection", withType: .bool, andIdentifier: MaplePreferencesController.injectionEnabledKey, forContainer: groupContainer) { newValue in
                                if let newValue = newValue as? Bool {
                                    MaplePreferencesController.shared.injectionEnabled = newValue
                                }
                            }
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Themed Color", description: "**No Effect**", withType: .color, andIdentifier: "dev.halz.Maple.prefs.general.themeColor", forContainer: groupContainer)
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Development Mode", description: "When enabled, development mode is active, allowing for detailed logs, faster rebuilds, and a better more secure development experience", withType: .bool, andIdentifier: MaplePreferencesController.developmentKey, forContainer: groupContainer) { newValue in
                                if let newValue = newValue as? Bool {
                                    MaplePreferencesController.shared.developmentEnabled = newValue
                                }
                            }
                        }
                }.withGroup { containerName in
                    PreferenceGroup(withName: "Development", andIdentifier: "dev.halz.Maple.app.prefs.developmentgroup", forContainer: containerName, optionallyShownIfKeyIsTrue: MaplePreferencesController.developmentKey)
                        .withPreference { groupContainer in
                            Preference(withTitle: "Security Key", description: "**NO EFFECT** This key must be included in your development leaf to help secure it", withType: .string, andIdentifier: "dev.halz.Maple.prefs.development.securityKey", forContainer: groupContainer)
                        }.withPreference { groupContainer in
                            Preference(withTitle: "Notify on install", description: "Maple will notify you when a development leaf is installed and begins injecting", withType: .bool, andIdentifier: MaplePreferencesController.developmentNotifyKey, forContainer: groupContainer) { newValue in
                                if let newValue = newValue as? Bool {
                                    MaplePreferencesController.shared.developmentNotify = newValue
                                }
                            }
                        }
                }
        }
        return Preferences.privateMapleAppPreferences!
    }
    
    static func fromLeaf(_ leaf: Leaf) -> Preferences? {
        guard let _ = leaf.leafID else { fatalError("Leaf should have bundle identifier") }
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
