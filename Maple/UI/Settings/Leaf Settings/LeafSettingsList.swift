//
//  LeafSettingsList.swift
//  Maple
//
//  Created by Hallie on 5/18/22.
//

import SwiftUI

struct LeafSettingsList: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedLeaf: Leaf?
    
    @ObservedObject var mapleController: MapleController = .shared
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.darkGray).opacity(self.colorScheme == .dark ? 0.4 : 0.2))
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    ForEach(self.mapleController.installedLeaves, id: \.self) { leaf in
                        LeafSettingsCell(leaf, selected: self.$selectedLeaf)
                    }
                }
            }.padding(4)
        }
    }
}
