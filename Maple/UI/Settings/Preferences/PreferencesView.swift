//
//  PreferencesView.swift
//  Maple
//
//  Created by Hallie on 6/1/22.
//

import SwiftUI
import MaplePreferences

struct PreferencesView: View {
    
    let preferences: Preferences
    
    var body: some View {
        VStack(alignment: .leading) {
            if let assorted = self.preferences.generalPreferences {
                ForEach(0..<assorted.count, id: \.self) { i in
                    PreferenceView(preference: assorted[i])
                }
            }
            
            if let groups = self.preferences.preferenceGroups {
                // Groups
                ForEach(groups, id: \.self) { group in
                    if group != groups.first {
                        Divider()
                    }
                    PreferencesGroupView(group: group)
                }
            }
        }
    }
}
