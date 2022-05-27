//
//  InstallStartView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct InstallStartView: View {
    
    @Binding var complete: Bool
    @Binding var title: String
    @Binding var leaf: Leaf?
    
    var body: some View {
        VStack {
            Text("Choose below if you would like to install or discard the tweak you approved on the last slide")
            
            HStack(spacing: 8) {
                MapleButton(action: {
                    guard let _ = self.leaf else { return }
                    try? MapleController.shared.installLeaf(self.leaf!)
                    self.complete = true
                }, title: "INSTALL AND START")
                MapleButton(action: {
                    print("Cancelling an install")
                    self.complete = true
                }, title: "DELETE AND CANCEL")
            }
            
        }.onAppear {
            self.complete = false
            self.title = "Confirm your Leaf package"
        }
    }
}
