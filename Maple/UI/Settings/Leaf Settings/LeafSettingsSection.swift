//
//  LeafSettingsSection.swift
//  Maple
//
//  Created by Hallie on 5/23/22.
//

import SwiftUI
import MaplePreferences

struct LeafSettingsSection: View {
    let leaf: Leaf
    
    @State var selectedEnabled: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Group { // About
                Text("About")
                    .font(.title2)
                    .bold()
                
                Text(self.leaf.name ?? "Name")
                    .font(.title3)
                    .bold()
                
                Text(self.leaf.leafDescription ?? "Description")
            }.padding(.horizontal)
            
            Divider()
            
            //TODO: This enablability toggle's only purpose is to control if it's enabled or not. Need to add some way to have an initial value for the preferences!
            BooleanPreferenceView(preference: Preference(withTitle: "Enabled", withType: .bool, andIdentifier: "unnessecary.identifier.for.identifiable", forContainer: self.leaf.leafID ?? "useless container", toRunOnSet: { newValue in
                if let value = newValue as? Bool {
                    if self.leaf.enabled != value {
                        self.leaf.toggleEnable()
                    }
                }
            })).padding(.horizontal)
            
            Group {
                if self.leaf.hasPreferences {
                    Divider()
                    if let prefs = self.leaf.preferences {
                        PreferencesView(preferences: prefs)
                            .padding(.horizontal)
                    } else {
                        Text("Error!")
                            .foregroundColor(.red)
                    }
                }
            }
        }.onAppear {
            self.selectedEnabled = self.leaf.enabled
        }
    }
}
