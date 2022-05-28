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
                    Text("Enabled")
                        .bold()
                }
            }.padding(.horizontal)
            
            Divider()
            
            Group { // Specific
                Text("\(self.leaf.name ?? "") Specific")
                    .font(.title2)
                    .bold()
                //TODO: Make this section display stuff the developer shipped with the leaf
            }.padding(.horizontal)
        }.onAppear {
            self.selectedEnabled = self.leaf.enabled
        }
    }
}
