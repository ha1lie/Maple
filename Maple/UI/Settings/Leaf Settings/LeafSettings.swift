//
//  LeafSettings.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct LeafSettings: View {
    @State var displayedLeaf: Leaf? = nil
    @ObservedObject var mapleController: MapleController = .shared
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                if self.mapleController.installedLeaves.count > 0 {
                    LeafSettingsList(selectedLeaf: self.$displayedLeaf)
                        .frame(width: max(min(geo.size.width / 3, 300), 200))
                        .onAppear {
                            if self.displayedLeaf == nil {
                                self.displayedLeaf = self.mapleController.installedLeaves[0]
                            }
                        }
                    ScrollView(.vertical, showsIndicators: true) {
                        if self.displayedLeaf != nil {
                            LeafSettingsSection(leaf: self.displayedLeaf!, displayedLeaf: self.$displayedLeaf)
                                .padding(.trailing)
                        } else {
                            Text("Select a Leaf")
                                .font(.title)
                                .bold()
                        }
                    }
                } else { // There are no leaves currently installed
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 12) {
                        Spacer()
                        Text("No Leaves Installed")
                            .foregroundColor(.gray)
                            .font(.title2)
                            .bold()
                        
                        Image(systemName: "xmark.octagon")
                            .foregroundColor(.gray)
                            .font(.system(size: 70))
                        
                        MapleButton(action: {
                            self.mapleController.openWindowToInstallLeaf()
                        }, title: "Install A Leaf")
                        Spacer()
                    }
                    
                    Spacer()
                }
            }.padding([.vertical, .leading])
            .onAppear {
                if let openedLeafIndex = MaplePreferencesController.shared.openedLeafIndex {
                    if self.mapleController.installedLeaves.count > openedLeafIndex {
                        self.displayedLeaf = self.mapleController.installedLeaves[openedLeafIndex]
                    }
                    
                    MaplePreferencesController.shared.openedLeafIndex = nil
                }
            }.onChange(of: self.displayedLeaf) { newValue in
                if newValue == nil && self.mapleController.installedLeaves.count > 0 {
                    self.displayedLeaf = self.mapleController.installedLeaves.first
                }
            }
        }
    }
}
