//
//  MapleButton.swift
//  Maple
//
//  Created by Hallie on 4/4/22.
//

import SwiftUI

/// Button which conforms to Maple's design style
struct MapleButton: View {
    /// Action performed when clicked
    let action: () -> Void
    /// Title to display on the button
    let title: String
    /// The size of the button
    let size: MapleButtonSize
    let color: Color
    
    init(action: @escaping () -> Void, title: String, withColor color: Color = .blue, andSize size: MapleButtonSize = .regular) {
        self.action = action
        self.title = title
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Button {
            self.action()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: self.size.rawValue / 4)
                    .foregroundColor(self.color)
                Text(self.title)
                    .padding(.horizontal)
                    .foregroundColor(.white)
            }.frame(height: self.size.rawValue).fixedSize()
        }.buttonStyle(PlainButtonStyle())
    }
}

enum MapleButtonSize: CGFloat {
    case small = 25
    case regular = 40
}
