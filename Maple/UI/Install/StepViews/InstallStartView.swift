//
//  InstallStartView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI
import MaplePreferences

struct InstallStartView: View {
    
    @Binding var complete: Bool
    @Binding var title: String
    @Binding var leaf: Leaf?
    @Binding var finished: Bool
    
    @State var killProcessOnStart: Bool = true
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading) {
                Text("Ready?!")
                    .font(.title2)
                    .bold()
                
                Text("You've given us the Leaf, and told us you trust it, ready to see it in action?")
                
                if MapleController.shared.installedLeaves.contains(where: { leaf in
                    return leaf.leafID == self.leaf?.leafID
                }) { // This leaf is already installed
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .foregroundColor(.yellow.opacity(0.3))
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.yellow)
                            Text("Installing this Leaf will uninstall the previous version")
                                .foregroundColor(.yellow)
                        }
                    }.frame(height: 60)
                }
                
                BooleanPreferenceView(preference: Preference(withTitle: "Enabled", withType: .bool, defaultValue: .bool(true), andIdentifier: "nil", forContainer: "nil", toRunOnSet: { newValue in
                    if let newBool = newValue as? Bool {
                        self.leaf?.enabled = newBool
                    }
                })).onAppear {
                    self.leaf?.enabled = true
                }
                
                BooleanPreferenceView(preference: Preference(withTitle: "Kill injected process on startup", description: "This will force whatever affected process to reload and inject new implementation", withType: .bool, defaultValue: .bool(true), andIdentifier: "nil", forContainer: "nil", toRunOnSet: { newValue in
                    if let newBool = newValue as? Bool { // Grr
                        self.leaf?.killOnInject = newBool
                    }
                })).onAppear {
                    self.leaf?.killOnInject = true
                }
                
                MapleButton(action: {
                    guard let _ = self.leaf else { return }
                    try? MapleController.shared.installLeaf(self.leaf!)
                    self.complete = true
                    self.finished = true
                }, title: "Install and Finalize")
                
                MapleButton(action: {
                    guard let _ = self.leaf else { return }
                    MapleController.shared.uninstallLeaf(self.leaf!)
                    self.complete = true
                    self.finished = true
                }, title: "Cancel", withColor: .red, andSize: .small)
            }
        }.onAppear {
            self.complete = false
            self.title = "Confirm your Leaf package"
        }
    }
}
