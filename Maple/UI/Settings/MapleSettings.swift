//
//  MapleSettings.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI
import MaplePreferences

struct MapleSettings: View {
    
    @State var injectionPermission: Bool = true
    @State var enableAtLogin: Bool = false
    
    @ObservedObject var prefsController: MaplePreferencesController = .shared
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                
                PreferencesView(preferences: Preferences.mapleAppPreferences)
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
            }.padding()
        }
    }
}
