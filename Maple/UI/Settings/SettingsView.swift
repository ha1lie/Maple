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
            
            MapleSegmentPicker(withOptions: ["Maple App", "Helper Tool", "Leaves"], andValue: self.$section)
                .padding(.horizontal)
            
            Group {
                if self.section == 0 {
                    MapleSettings()
                } else if self.section == 1 {
                    HelperSettings()
                } else {
                    LeafSettings()
                }
            }
        }.padding([.top])
    }
}
