//
//  LeafSettings.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct LeafSettings: View {
    @State var displayedLeaf: Leaf? = nil
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                LeafSettingsList(selectedLeaf: self.$displayedLeaf)
                    .frame(width: max(min(geo.size.width / 3, 300), 200))
                ScrollView(.vertical, showsIndicators: true) {
                    if self.displayedLeaf != nil {
                        LeafSettingsSection(leaf: self.displayedLeaf!)
                    } else {
                        Text("Select a Leaf")
                            .font(.title)
                            .bold()
                    }
                }
            }
        }
    }
}
