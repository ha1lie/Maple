//
//  LeafCell.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct LeafCell: View {
    
    let leaf: Leaf
    
    @Binding var selectedLeaf: Leaf?
    
    init(_ l: Leaf, withSelected s: Binding<Leaf?>) {
        self.leaf = l
        self._selectedLeaf = s
    }
    
    var body: some View {
        Button {
            self.selectedLeaf = self.leaf
        } label: {
            HStack {
                if let iName = self.leaf.imageName {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        Image(systemName: iName)
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(self.leaf.name ?? "LEAF NAME")
                        .bold()
                    Text(self.leaf.description ?? "LEAF DESCRIPTION")
                }
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 3)
                    .frame(width: 6, height: 6)
                    .foregroundColor(self.leaf.enabled ? .green : .red)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }.frame(height: 60)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
