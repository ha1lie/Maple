//
//  LeafDetailView.swift
//  Maple
//
//  Created by Hallie on 4/15/22.
//

import SwiftUI

/// Detail view about a Leaf
struct LeafDetailView: View {
    @Binding var selectedLeaf: Leaf?
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack {
                HStack {
                    Button {
                        self.selectedLeaf = nil
                    } label: {
                        // Image here
                        Text("BACK")
                    }
                    
                    Spacer()
                    Text(self.selectedLeaf?.name ?? "NAME")
                        .bold()
                        .font(.title)
                }
                
                Text("Created by *\(self.selectedLeaf?.author ?? "AUTHOR")*")
                ForEach(self.selectedLeaf?.targetBundleID ?? [], id: \.self) { bid in
                    Text("Modifies: *\(bid)*")
                }
                
                MapleButton(action: {
                    let answer = MapleNotificationController.shared.sendUserDialogue(withTitle: "Enable?", andBody: "Would you like to \(self.selectedLeaf?.enabled ?? true ? "disable" : "enable") \(self.selectedLeaf?.name ?? "NAME")", withOptions: ["YES", "NO"])
                    
                    if answer == "YES" {
                        self.selectedLeaf?.toggleEnable()
                        self.selectedLeaf = nil
                    }
                }, title: (self.selectedLeaf?.enabled ?? true) ? "DISABLE" : "ENABLE")
                
                MapleButton(action: {
                    print("OPEN THE PREFERENCES PANEL")
                }, title: "SETTINGS")
            }
        }.padding()
    }
}
