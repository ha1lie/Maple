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
            
            BooleanPreferenceView(preference: Preference(withTitle: "Enabled", withType: .bool, defaultValue: .bool(self.leaf.enabled), andIdentifier: "nil", forContainer: "nil", toRunOnSet: { newValue in
                if let value = newValue as? Bool {
                    if self.leaf.enabled != value {
                        self.leaf.toggleEnable()
                    }
                }
            })).padding(.horizontal)
            
            BooleanPreferenceView(preference: Preference(withTitle: "Kill injected process on startup", description: "Will kill the affected process if currently running to ensure any changes are made", withType: .bool, defaultValue: .bool(self.leaf.killOnInject), andIdentifier: "nil", forContainer: "nil", toRunOnSet: { newValue in
                if let value = newValue as? Bool {
                    self.leaf.killOnInject = value
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
            
            Divider()
                .padding(.top, 50)
            
            Group {
                Text("Danger Zone")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.red)
                    .padding(.bottom, 6)
                
                Button {
                    MapleController.shared.uninstallLeaf(self.leaf)
                } label: {
                    HStack {
                        Text("Uninstall Leaf")
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                    }.foregroundColor(.red.opacity(0.7))
                }.buttonStyle(PlainButtonStyle())
            }.padding(.horizontal)
        }.onAppear {
            self.selectedEnabled = self.leaf.enabled
        }
    }
}
