//
//  LeafSettingsCell.swift
//  Maple
//
//  Created by Hallie on 5/21/22.
//

import SwiftUI

struct LeafSettingsCell: View {
    @State var leaf: Leaf
    @Binding var selected: Leaf?
    
    init(_ leaf: Leaf, selected: Binding<Leaf?> = .constant(nil)) {
        self.leaf = leaf
        self._selected = selected
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.darkGray).opacity(self.leaf == self.selected ? 0.2 : 0.5))
                .frame(height: 60)
                .animation(.easeInOut(duration: 0.1), value: self.selected)
            
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 2)
                    .frame(width: 4)
                    .foregroundColor(self.leaf.enabled ? .green : .red)
                    .padding(.vertical, 12)
                    .padding(.leading, 4)
                
                Image(systemName: self.leaf.imageName ?? "leaf.fill")
                    .font(.system(size: 20))
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(self.leaf.name ?? "LEAF NAME")
                        .bold()
                        .lineLimit(1)
                    
                    Text(self.leaf.description ?? "DESCRIPTION")
                        .lineLimit(2)
                }
                
                Spacer()
            }.padding(4)
        }.onTapGesture {
            if self.selected != self.leaf {
                self.selected = self.leaf
            } else {
                self.selected = nil
            }
        }
    }
}
