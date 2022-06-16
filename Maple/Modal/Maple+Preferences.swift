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
                        Preference(withTitle: "Enable at Login", description: "Allow Maple to launch at login and enable your leaves without doing anything", withType: .bool, andIdentifier: "dev.halz.Maple.prefs.general.loginEnabled", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        Preference(withTitle: "Enable Injection", withType: .bool, andIdentifier: "dev.halz.Maple.prefs.general.enabledInjection", forContainer: groupContainer)
                    }.withPreference { groupContainer in
                        Preference(withTitle: "Themed Color", withType: .color, andIdentifier: "dev.halz.Maple.prefs.general.themeColor", forContainer: groupContainer)
                    }
            }.withGroup { containerName in
                PreferenceGroup(withName: "Development", andIdentifier: "dev.halz.Maple.prefs.development", forContainer: containerName)
                    .withPreference { groupContainer in
                        Preference(withTitle: "Development Mode", description: "When enabled, development mode is active, allowing for detailed logs, faster rebuilds, and a better more secure development experience", withType: .bool, andIdentifier: "dev.halz.Maple.prefs.general.enableDevelopment", forContainer: groupContainer)
                    }
            } as! Self
    }
    
    public static func fromBID(_ bid: String) -> Self? {
        return nil
    }
}
