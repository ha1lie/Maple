//
//  LeafDetailView.swift
//  Maple
//
//  Created by Hallie on 4/15/22.
//

import SwiftUI
import MaplePreferences

/// Detail view about a Leaf
struct LeafDetailView: View {
    @Binding var selectedLeaf: Leaf?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            if let leaf = self.selectedLeaf {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        MapleButton(action: {
                            withAnimation {
                                self.selectedLeaf = nil
                            }
                        }, title: "Back", andSize: .small)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            if leaf.development {
                                Text("DEVELOPMENT")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .bold()
                            }
                            if let name = leaf.name {
                                Text(name)
                                    .bold()
                                    .font(.title)
                            }
                        }
                        
                        RoundedRectangle(cornerRadius: 2)
                            .foregroundColor(leaf.enabled ? .green : .red)
                            .frame(width: 4)
                    } // End header
                    
                    Divider()
                    
                    BooleanPreferenceView(preference: Preference(withTitle: "Enabled", withType: .bool, andIdentifier: "unnessecary.identifier.for.identifiable", forContainer: leaf.leafID ?? "useless container", toRunOnSet: { newValue in
                        if let value = newValue as? Bool {
                            if leaf.enabled != value {
                                leaf.toggleEnable()
                            }
                        }
                    }))
                    
                    Group {
                        Text("About")
                            .bold()
                            .font(.title2)
                        
                        if let description = leaf.leafDescription {
                            Text(description)
                        }
                        
                        if let website = leaf.tweakWebsite {
                            Button {
                                if let webURL = URL(string: website) {
                                    NSWorkspace.shared.open(webURL)
                                }
                            } label: {
                                HStack(alignment: .center) {
                                    Text("See online")
                                    Image(systemName: "arrow.right")
                                        .padding(.leading, -4)
                                }.foregroundColor(.accentColor)
                            }.buttonStyle(PlainButtonStyle())
                            .padding(.bottom)
                        }
                        
                        if let author = leaf.author {
                            Text("**Author:** \(author)")
                        }
                        
                        if let discord = leaf.authorDiscord {
                            Text("**Creator's Discord:** \(discord)")
                        }
                        
                        if let email = leaf.authorEmail {
                            Button {
                                if let emailURL = URL(string: "mailto:\(email)") {
                                    NSWorkspace.shared.open(emailURL)
                                }
                            } label: {
                                HStack(alignment: .center) {
                                    Text("Email creator")
                                    Image(systemName: "arrow.right")
                                        .padding(.leading, -4)
                                }.foregroundColor(.accentColor)
                            }.buttonStyle(PlainButtonStyle())
                            .padding(.bottom)
                        }
                        
                        if let process = leaf.targetBundleID?[0] {
                            Text("**Injects into:** \(process)")
                        }
                    }
                    
                    if leaf.hasPreferences {
                        HStack {
                            Spacer()
                            MapleButton(action: {
                                MaplePreferencesController.shared.openedPanel = 2
                                MaplePreferencesController.shared.openedLeafIndex = MapleController.shared.installedLeaves.firstIndex(of: leaf)
                                MapleController.shared.openSettingsWindow()
                            }, title: "Open Preferences", andSize: .small)
                            Spacer()
                        }
                    }
                }.padding()
            } else {
                EmptyView()
            }
        }
    }
}
