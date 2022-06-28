//
//  LeafSettingsCell.swift
//  Maple
//
//  Created by Hallie on 5/21/22.
//

import SwiftUI

struct LeafSettingsCell: View {
    @ObservedObject var leaf: Leaf
    @Binding var selected: Leaf?
    @Environment(\.colorScheme) var colorScheme
    
    var backgroundOpacity: CGFloat {
        if self.leaf == self.selected {
            if self.colorScheme == .dark {
                return 0.2
            } else {
                return 0.05
            }
        } else {
            if self.colorScheme == .dark {
                return 0.5
            } else {
                return 0.3
            }
        }
    }
    
    init(_ leaf: Leaf, selected: Binding<Leaf?> = .constant(nil)) {
        self.leaf = leaf
        self._selected = selected
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(Color(.darkGray).opacity(self.leaf == self.selected ? 0.2 : 0.5))
                .frame(height: self.leaf.development ? 75 : 60)
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
                    if self.leaf.development {
                        Text("DEVELOPMENT")
                            .foregroundColor(.gray)
                            .font(.caption)
                            .bold()
                    }
                    
                    if let name = self.leaf.name {
                        Text(name)
                            .bold()
                            .lineLimit(1)
                    }
                }
                
                Spacer()
            }.padding(4)
        }.onTapGesture {
            withAnimation {
                if self.selected != self.leaf {
                    self.selected = self.leaf
                }
            }
        }
    }
}
