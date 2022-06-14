//
//  Maple+Preferences.swift
//  Maple
//
//  Created by Hallie on 6/12/22.
//

import Foundation
import MaplePreferences

extension Preferences {
    static var mapleAppPreferences: Preferences {
        return Preferences(forBundle: "dev.halz.Maple.app")
            .withGroup { containerName in
                PreferenceGroup(withName: "General", description: "General pickings and choosings", andIdentifier: "dev.halz.Maple.prefs.general", forContainer: containerName)
                    .withPreference { groupContainer in
                        BoolPreference(withTitle: "Enable At Login", description: "Allow Maple to launch at login and enable your leaves without doing anything", defaultValue: false, andIdentifier: "dev.halz.Maple.prefs.general.loginEnabled", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        BoolPreference(withTitle: "Enable Injection", defaultValue: true, andIdentifier: "dev.halz.Maple.prefs.general.enabledInjection", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        ColorPreference(withTitle: "Themed Color", defaultValue: .red, andIdentifier: "dev.halz.Maple.prefs.general.themeColor", forContainer: groupContainer)
                    }
            }.withGroup { containerName in
                PreferenceGroup(withName: "Development", andIdentifier: "dev.halz.Maple.prefs.development", forContainer: containerName)
                    .withPreference { groupContainer in
                        BoolPreference(withTitle: "Development Mode", description: "When enabled, developoment mode is active, allowing for detailed logs, faster rebuilds, and a better more secure development experience", defaultValue: false, andIdentifier: "dev.halz.Maple.prefs.general.enableDevelopment", forContainer: groupContainer)
                    }
            }
    }
    
    public static func fromBID(_ bid: String) -> Preferences? {
        return nil
    }
}
