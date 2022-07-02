//
//  MapleSettings.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI
import MaplePreferences
import LaunchAtLogin

struct MapleSettings: View {
    
    @State var injectionPermission: Bool = true
    @State var enableAtLogin: Bool = false
    
    @ObservedObject var prefsController: MaplePreferencesController = .shared
    @ObservedObject var helperMonitor: HelperToolMonitor
    
    @ObservedObject var launch = LaunchAtLogin.observable
    
    init() {
        guard let hm = (NSApplication.shared.delegate as? AppDelegate)?.helperMonitor else {
            MapleLogController.shared.local(log: "ERROR Fatal Error Occured because Helper Monitor should always be accessible")
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

                    Group {
                        Text("Installed Versions")
                            .font(.title)
                            .bold()
                        
                        Text("**Maple Version:** \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown Version")")
                        
                        Text("**Helper Version:** \(self.helperMonitor.helperToolBundleVersion?.rawValue ?? "Unknown Version")")
                        
                        Text("**Injector Version:** v1.0")
                        
                        Button {
                            if let injectorGithub = URL(string: "https://github.com/ha1lie/Maple-LibInjector") {
                                NSWorkspace.shared.open(injectorGithub)
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text("View on Github")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                            }.foregroundColor(.accentColor)
                        }.buttonStyle(PlainButtonStyle())
                        
                        Text("**MacOS Version:** \(ProcessInfo.processInfo.operatingSystemVersionString)")
                    }
                    
                    Text("**Copyright 2022 Hallie**")
                    
                    Group {
                        Divider()
                            .padding(.horizontal)
                        
                        Text("Danger Zone")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.red)
                        
                        MapleButton(action: {
                            MapleController.shared.uninstallInjector()
                        }, title: "Remove Files from /Library", withColor: .red, andSize: .small)
                    }
                }
            }.padding()
        }
    }
}
