//
//  MapleHoverButton.swift
//  Maple
//
//  Created by Hallie on 6/21/22.
//

import SwiftUI

struct MapleHoverButton: View {
    let action: () -> Void
    let title: String
    let imageName: String
    
    @State var isHovered: Bool = false
    
    var body: some View {
        Button {
            self.action()
        } label: {
            ZStack {
                if self.isHovered {
                    RoundedRectangle(cornerRadius: 4).foregroundColor(.accentColor)
                }
                HStack {
                    Text(self.title)
                    Spacer()
                    Image(systemName: self.imageName)
                }.padding()
            }.onHover { hovered in
                self.isHovered = hovered
            }
        }.buttonStyle(PlainButtonStyle())
    }
}
