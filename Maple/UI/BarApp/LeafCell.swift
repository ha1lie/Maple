//
//  LeafCell.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

struct LeafCell: View {
    
    let leaf: Leaf
    
    init(_ l: Leaf) {
        self.leaf = l
    }
    
    var body: some View {
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
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
    }
}
