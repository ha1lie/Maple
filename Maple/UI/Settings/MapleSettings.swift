//
//  MapleSettings.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct MapleSettings: View {
    
    @State var injectionPermission: Bool = true
    @State var enableAtLogin: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Toggle(isOn: self.$injectionPermission, label: {})
                        .toggleStyle(SwitchToggleStyle())
                        .tint(.purple)
                    Text("Allowed to Inject")
                        .bold()
                }
                Text("If disabled, Maple will not be able to inject into running processes to enable Leaves")
                    .font(.caption)
                    .padding(.leading, 16)
                
                HStack(spacing: 4) {
                    Toggle(isOn: self.$enableAtLogin, label: {})
                        .toggleStyle(SwitchToggleStyle())
                        .tint(.purple)
                    Text("Launch At Login")
                        .bold()
                }
                Text("When enabled, Maple will launch at Login, and automatically start injecting after a reboot or login")
                    .font(.caption)
                    .padding(.leading, 16)
                
                Divider()
                
                VStack(alignment: .center, spacing: 8) {
                    Text("About")
                        .font(.title2)
                        .bold()
                    Text("Maple is a MacOS customization and eventually security add-on to allow a user to take complete control over their device, for any purpose.")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                    
                    Text("Maple Version **1.2** installed on **MacOS 12.5.1 Monterey**, paired with helper tool version **1.0.0d96** for the perfect pair")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14))
                    
                    Text("Copyright 2022 Hallie")
                }
            }
        }
    }
}
