//
//  LeafSettingsSection.swift
//  Maple
//
//  Created by Hallie on 5/23/22.
//

import SwiftUI

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
            
            Group { // General
                Text("General")
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 4) {
                    Toggle(isOn: self.$selectedEnabled) {}
                        .toggleStyle(SwitchToggleStyle())
                        .tint(.purple)
                        .rotationEffect(Angle(degrees: 270))
                    Text("Enabled")
                        .bold()
                }
            }.padding(.horizontal)
            
            if self.leaf.hasPreferences {
                Divider()
                if let prefs = self.leaf.preferences {
                    Group {
                        Text("\(self.leaf.name ?? "") Specific")
                            .font(.title2)
                            .bold()
                        PreferencesView(preferences: prefs)
                    }.padding(.horizontal)
                    
                } else {
                    Group { // Display an error message
                        Text("Uh oh!")
                            .font(.system(size: 30))
                            .bold()
                            .foregroundColor(.gray)
                        Text("We've had a problem trying to get to your settings! I'm so sorry! Please try again, or quit the app to reload")
                    }.padding(.horizontal)
                    
                }
            }
        }.onAppear {
            self.selectedEnabled = self.leaf.enabled
        }
    }
}
