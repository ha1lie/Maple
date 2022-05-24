//
//  LeafSettingsList.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct LeafSettingsList: View {
    
    @Binding var selectedLeaf: Leaf?
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.darkGray).opacity(0.4))
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(MapleController.shared.installedLeaves, id: \.self) { leaf in
                        LeafSettingsCell(leaf, selected: self.$selectedLeaf)
                    }
                }
            }.padding(4)
        }
    }
}
