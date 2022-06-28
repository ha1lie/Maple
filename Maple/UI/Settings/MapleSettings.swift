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
    @ObservedObject var helperMonitor: HelperToolMonitor
    
    init() {
        guard let hm = (NSApplication.shared.delegate as? AppDelegate)?.helperMonitor else {
            fatalError("Helper Monitor should be accessible")
        }
        self.helperMonitor = hm
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                
                PreferencesView(preferences: Preferences.mapleAppPreferences)
                Divider()
                
                //SECTION: About Maple
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.title2)
                        .bold()
                    Text("Maple is a MacOS customization, injection runtime replacement utility. It allows a user to take complete control over their Mac.")
                    
                    Button {
                        if let mapleWebsite = URL(string: "https://www.google.com") {
                            NSWorkspace.shared.open(mapleWebsite)
                        }
                    } label: {
                        HStack(alignment: .center) {
                            Text("Read more online")
                            
                            Image(systemName: "arrow.right")
                                .padding(.leading, -4)
                        }.foregroundColor(.accentColor)
                    }.buttonStyle(PlainButtonStyle())

                    
                    Text("Installed Versions")
                        .font(.title)
                        .bold()
                    
                    Text("**Maple Version:** \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Version")")
                    
                    Text("**Helper Version:** \(self.helperMonitor.helperToolBundleVersion?.rawValue ?? "Unknown Version")")
                    
                    Text("**MacOS Version:** \(ProcessInfo.processInfo.operatingSystemVersionString)")
                    
                    Text("**Copyright 2022 Hallie**")
                }
            }.padding()
        }
    }
}
