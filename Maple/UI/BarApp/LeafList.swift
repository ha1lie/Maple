//
//  LeafList.swift
//  Maple
//
//  Created by Hallie on 4/15/22.
//

import SwiftUI

/// A list displaying all installed leaves
struct LeafList: View {
    @ObservedObject var mapleController: MapleController = .shared
    @ObservedObject var developmentHelper: MapleDevelopmentHelper = .shared
    @Binding var selectedLeaf: Leaf?
    
    @State var showOtherOptions: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Maple")
                    .font(.title)
                    .bold()
                Spacer()

                Image(systemName: "ellipsis")
                    .onHover { hovered in
                        self.showOtherOptions = true
                    }.popover(isPresented: self.$showOtherOptions) {
                        VStack {
                            MapleHoverButton(action: {
                                self.mapleController.openSettingsWindow()
                            }, title: "Settings", imageName: "gear")
                            
                            MapleHoverButton(action: {
                                NSApp.terminate(self)
                            }, title: "Quit", imageName: "stop.circle.fill")
                            
                            MapleHoverButton(action: {
                                self.mapleController.openLogWindow()
                            }, title: "Logs", imageName: "newspaper.circle")
                        }.frame(width: 200, height: 150)
                        .onHover { hovered in
                            self.showOtherOptions = hovered
                        }
                    }
                
                MapleButton(action: {
                    self.mapleController.openWindowToInstallLeaf()
                }, title: "New")
            }
            
            if self.mapleController.installedLeaves.count == 0 {
                Text("You don't have any Leaves installed currently")
            } else {
                LeafSettingsList(selectedLeaf: self.$selectedLeaf)
            }
        }.padding()
    }
}
