//
//  SettingsView.swift
//  Maple
//
//  Created by Hallie on 5/1/22.
//

import SwiftUI

/// Window to display the app's settings
struct SettingsView: View {
    @State var section: Int = 0
    
    var body: some View {
        VStack {
            Text("Maple Settings")
                .font(.title)
                .bold()
            
            Picker("", selection: self.$section) {
                Text("Maple App").tag(0)
                Text("Helper Tool").tag(1)
                Text("Leaves").tag(2)
            }.pickerStyle(.segmented)
            
            MapleSegmentPicker(withOptions: ["Maple App", "Helper Tool", "Leaves"], andValue: self.$section)
            
            ScrollView(.vertical, showsIndicators: true) {
                if self.section == 0 {
                    MapleSettings()
                } else if self.section == 1 {
                    HelperSettings()
                } else {
                    LeafSettings()
                }
            }.padding()
        }.padding()
    }
}
